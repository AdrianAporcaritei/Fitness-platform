package com.anafitlab.backend.client;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

/**
 * The coach's client list: pending invites (INVITED) and coach_client relationships in one paginated,
 * name-ordered result. Only the parts needed for the requested status are queried.
 */
@Repository
class ClientListQuery {

	private static final String INVITED = """
			SELECT i.id, i.label AS name, i.email, 'INVITED' AS status, i.created_at AS invited_at,
			       i.expires_at AS invitation_expires_at
			FROM coach_invite i
			WHERE i.coach_id = :coachId AND i.status = 'PENDING'
			""";

	private static final String CURRENT = """
			SELECT u.id, u.first_name || ' ' || u.last_name AS name, u.email, c.status, c.invited_at,
			       NULL::timestamptz AS invitation_expires_at
			FROM coach_client c JOIN app_user u ON u.id = c.client_id
			WHERE c.coach_id = :coachId AND c.status IN (:currentStatuses)
			""";

	/** One row per former client (the most recent relationship), unless the client is linked again. */
	private static final String ENDED = """
			SELECT * FROM (
			    SELECT DISTINCT ON (c.client_id) u.id, u.first_name || ' ' || u.last_name AS name, u.email,
			           c.status, c.invited_at, NULL::timestamptz AS invitation_expires_at
			    FROM coach_client c JOIN app_user u ON u.id = c.client_id
			    WHERE c.coach_id = :coachId AND c.status = 'ENDED'
			      AND NOT EXISTS (SELECT 1 FROM coach_client cur
			                      WHERE cur.coach_id = c.coach_id AND cur.client_id = c.client_id
			                        AND cur.status IN ('ACTIVE', 'PAUSED'))
			    ORDER BY c.client_id, c.ended_at DESC NULLS LAST, c.created_at DESC
			) ended
			""";

	private final NamedParameterJdbcTemplate jdbc;

	ClientListQuery(NamedParameterJdbcTemplate jdbc) {
		this.jdbc = jdbc;
	}

	record Row(UUID id, String name, String email, ClientListStatus status, Instant invitedAt,
			Instant invitationExpiresAt) {
	}

	record Result(List<Row> rows, long total) {
	}

	/**
	 * @param status null for the default list (INVITED, ACTIVE and PAUSED)
	 * @param search null or blank for no search; otherwise a case-insensitive substring of name or email
	 */
	Result find(UUID coachId, ClientListStatus status, String search, int page, int size) {
		MapSqlParameterSource params = new MapSqlParameterSource("coachId", coachId);
		String roster = roster(status, params);
		String where = "";
		if (search != null && !search.isBlank()) {
			where = " WHERE lower(coalesce(name, '')) LIKE :pattern ESCAPE '\\' OR lower(coalesce(email, '')) LIKE :pattern ESCAPE '\\'";
			params.addValue("pattern", "%" + escapeLike(search.strip().toLowerCase(Locale.ROOT)) + "%");
		}
		String from = " FROM (" + roster + ") roster" + where;

		Long total = jdbc.queryForObject("SELECT count(*)" + from, params, Long.class);
		params.addValue("limit", size).addValue("offset", (long) page * size);
		List<Row> rows = jdbc.query(
				"SELECT *" + from + " ORDER BY lower(coalesce(name, '')), id LIMIT :limit OFFSET :offset", params,
				(rs, n) -> row(rs));
		return new Result(rows, total == null ? 0 : total);
	}

	private static String roster(ClientListStatus status, MapSqlParameterSource params) {
		List<String> parts = new ArrayList<>();
		if (status == null || status == ClientListStatus.INVITED) {
			parts.add(INVITED);
		}
		if (status == null || status == ClientListStatus.ACTIVE || status == ClientListStatus.PAUSED) {
			parts.add(CURRENT);
			params.addValue("currentStatuses", status == null ? List.of("ACTIVE", "PAUSED") : List.of(status.name()));
		}
		if (status == ClientListStatus.ENDED) {
			parts.add(ENDED);
		}
		return String.join(" UNION ALL ", parts);
	}

	private static String escapeLike(String value) {
		return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
	}

	private static Row row(ResultSet rs) throws SQLException {
		return new Row(rs.getObject("id", UUID.class), rs.getString("name"), rs.getString("email"),
				ClientListStatus.valueOf(rs.getString("status")), instant(rs.getTimestamp("invited_at")),
				instant(rs.getTimestamp("invitation_expires_at")));
	}

	private static Instant instant(Timestamp timestamp) {
		return timestamp == null ? null : timestamp.toInstant();
	}

}
