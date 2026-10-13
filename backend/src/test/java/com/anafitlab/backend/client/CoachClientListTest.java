package com.anafitlab.backend.client;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasKey;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Duration;
import java.time.Instant;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.client.entity.CoachClient;
import com.anafitlab.backend.client.entity.CoachInvite;
import com.anafitlab.backend.client.entity.InviteStatus;
import com.anafitlab.backend.client.entity.RelationshipStatus;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.MutableClock;
import com.anafitlab.backend.support.TestFixtures;

class CoachClientListTest extends IntegrationTestBase {

	@Autowired
	MockMvc mockMvc;

	@Autowired
	TestFixtures fixtures;

	@Autowired
	MutableClock clock;

	@Autowired
	JdbcTemplate jdbc;

	private AppUser coach(String email) {
		return fixtures.user(Role.COACH, UserStatus.ACTIVE, email);
	}

	private AppUser client(String first, String last, String email) {
		return fixtures.user(Role.CLIENT, UserStatus.ACTIVE, email, first, last);
	}

	private CoachInvite pending(AppUser coach, String name, String email) {
		return fixtures.invite(coach, name, email, InviteStatus.PENDING, clock.instant().plus(Duration.ofDays(7)));
	}

	private ResultActions list(AppUser actor, String... params) throws Exception {
		MockHttpServletRequestBuilder request = get("/api/v1/coach/clients").header(HttpHeaders.AUTHORIZATION,
				fixtures.bearer(actor));
		for (int i = 0; i < params.length; i += 2) {
			request.param(params[i], params[i + 1]);
		}
		return mockMvc.perform(request);
	}

	@Test
	void requiresAuthentication() throws Exception {
		mockMvc.perform(get("/api/v1/coach/clients")).andExpect(status().isUnauthorized());
	}

	@Test
	void clientAndAdminCannotList() throws Exception {
		AppUser client = client("Ana", "Pop", "cl@x.test");
		AppUser admin = fixtures.user(Role.ADMIN, UserStatus.ACTIVE, "ad@x.test");
		list(client).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
		list(admin).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
	}

	@Test
	void defaultListHasOwnInvitedActiveAndPausedRowsOnly() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser other = coach("o@x.test");
		fixtures.link(coach, client("Ana", "Active", "a@x.test"), RelationshipStatus.ACTIVE);
		fixtures.link(coach, client("Paul", "Paused", "p@x.test"), RelationshipStatus.PAUSED);
		fixtures.link(coach, client("Eve", "Ended", "e@x.test"), RelationshipStatus.ENDED);
		pending(coach, "Ivan Invited", "i@x.test");
		fixtures.invite(coach, "Xena Expired", "x@x.test", InviteStatus.PENDING, clock.instant().minusSeconds(1));
		fixtures.invite(coach, "Uma Used", "u@x.test", InviteStatus.USED, clock.instant().plus(Duration.ofDays(1)));
		fixtures.invite(coach, "Rita Revoked", "r@x.test", InviteStatus.REVOKED, clock.instant().plus(Duration.ofDays(1)));
		fixtures.link(other, client("Fred", "Foreign", "f@x.test"), RelationshipStatus.ACTIVE);
		pending(other, "Fiona Foreign", "fi@x.test");

		list(coach).andExpect(status().isOk())
			.andExpect(jsonPath("$.totalItems").value(4))
			.andExpect(jsonPath("$.totalPages").value(1))
			.andExpect(jsonPath("$.page").value(0))
			.andExpect(jsonPath("$.size").value(20))
			.andExpect(jsonPath("$.items[*].name").value(contains("Ana Active", "Ivan Invited", "Paul Paused",
					"Xena Expired")))
			.andExpect(jsonPath("$.items[*].status").value(contains("ACTIVE", "INVITED", "PAUSED", "INVITED")));
	}

	@Test
	void rowsCarryIdsDatesAndExpiryButNeverCodes() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser linked = client("Ana", "Pop", "ana@x.test");
		CoachClient link = fixtures.link(coach, linked, RelationshipStatus.ACTIVE);
		Instant invitedAt = Instant.parse("2026-01-02T10:00:00Z");
		jdbc.update("UPDATE coach_client SET invited_at = ? WHERE id = ?", java.sql.Timestamp.from(invitedAt),
				link.getId());
		CoachInvite fresh = pending(coach, "Bia Fresh", "bia@x.test");
		CoachInvite stale = fixtures.invite(coach, "Cleo Stale", "cleo@x.test", InviteStatus.PENDING,
				clock.instant().minusSeconds(1));

		list(coach).andExpect(status().isOk())
			.andExpect(jsonPath("$.items[0].id").value(linked.getId().toString()))
			.andExpect(jsonPath("$.items[0].email").value("ana@x.test"))
			.andExpect(jsonPath("$.items[0].invitedAt").value(invitedAt.toString()))
			.andExpect(jsonPath("$.items[0].invitationExpiresAt").value(nullValue()))
			.andExpect(jsonPath("$.items[0].invitationExpired").value(false))
			.andExpect(jsonPath("$.items[1].id").value(fresh.getId().toString()))
			.andExpect(jsonPath("$.items[1].email").value("bia@x.test"))
			.andExpect(jsonPath("$.items[1].invitedAt").exists())
			.andExpect(jsonPath("$.items[1].invitationExpiresAt").value(fresh.getExpiresAt().toString()))
			.andExpect(jsonPath("$.items[1].invitationExpired").value(false))
			.andExpect(jsonPath("$.items[2].id").value(stale.getId().toString()))
			.andExpect(jsonPath("$.items[2].invitationExpired").value(true))
			.andExpect(jsonPath("$.items[1]", not(hasKey("code"))))
			.andExpect(jsonPath("$.items[1]", not(hasKey("link"))));
	}

	@Test
	void filtersByStatus() throws Exception {
		AppUser coach = coach("c@x.test");
		fixtures.link(coach, client("Ana", "Active", "a@x.test"), RelationshipStatus.ACTIVE);
		fixtures.link(coach, client("Paul", "Paused", "p@x.test"), RelationshipStatus.PAUSED);
		fixtures.link(coach, client("Eve", "Ended", "e@x.test"), RelationshipStatus.ENDED);
		pending(coach, "Ivan Invited", "i@x.test");

		list(coach, "status", "INVITED").andExpect(jsonPath("$.items[*].name").value(contains("Ivan Invited")));
		list(coach, "status", "ACTIVE").andExpect(jsonPath("$.items[*].name").value(contains("Ana Active")));
		list(coach, "status", "PAUSED").andExpect(jsonPath("$.items[*].name").value(contains("Paul Paused")));
		list(coach, "status", "ENDED").andExpect(jsonPath("$.items[*].name").value(contains("Eve Ended")))
			.andExpect(jsonPath("$.items[0].status").value("ENDED"))
			.andExpect(jsonPath("$.totalItems").value(1));
	}

	@Test
	void endedShowsOneRowPerFormerClientOnly() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser other = coach("o@x.test");
		AppUser twice = client("Tom", "Twice", "t@x.test");
		fixtures.link(coach, twice, RelationshipStatus.ENDED);
		fixtures.link(coach, twice, RelationshipStatus.ENDED);
		AppUser back = client("Bob", "Back", "b@x.test");
		fixtures.link(coach, back, RelationshipStatus.ENDED);
		fixtures.link(coach, back, RelationshipStatus.ACTIVE);
		AppUser moved = client("Mia", "Moved", "m@x.test");
		fixtures.link(coach, moved, RelationshipStatus.ENDED);
		fixtures.link(other, moved, RelationshipStatus.ACTIVE);
		fixtures.link(other, client("Olga", "Other", "ol@x.test"), RelationshipStatus.ENDED);

		list(coach, "status", "ENDED").andExpect(jsonPath("$.totalItems").value(2))
			.andExpect(jsonPath("$.items[*].name").value(contains("Mia Moved", "Tom Twice")));
	}

	@Test
	void searchesNameAndEmailCaseInsensitively() throws Exception {
		AppUser coach = coach("c@x.test");
		fixtures.link(coach, client("Ana", "Popescu", "ana.p@mail.test"), RelationshipStatus.ACTIVE);
		fixtures.link(coach, client("Dan", "Ionescu", "dan@work.test"), RelationshipStatus.ACTIVE);
		pending(coach, "Maria Pavel", "maria@mail.test");
		pending(coach, "Old Invite", null);
		fixtures.link(coach(("o@x.test")), client("Ana", "Foreign", "ana.f@mail.test"), RelationshipStatus.ACTIVE);

		list(coach, "q", "ana").andExpect(jsonPath("$.items[*].name").value(contains("Ana Popescu")));
		list(coach, "q", "ANA POP").andExpect(jsonPath("$.items[*].name").value(contains("Ana Popescu")));
		list(coach, "q", "ionescu").andExpect(jsonPath("$.items[*].name").value(contains("Dan Ionescu")));
		list(coach, "q", "@MAIL.test").andExpect(jsonPath("$.items[*].name")
			.value(containsInAnyOrder("Ana Popescu", "Maria Pavel")));
		list(coach, "q", "pavel").andExpect(jsonPath("$.items[*].name").value(contains("Maria Pavel")));
		list(coach, "q", "  ").andExpect(jsonPath("$.totalItems").value(4));
		list(coach, "q", "ana", "status", "INVITED").andExpect(jsonPath("$.totalItems").value(0));
	}

	@Test
	void searchTreatsWildcardsLiterally() throws Exception {
		AppUser coach = coach("c@x.test");
		fixtures.link(coach, client("Ana", "Pop", "ana@x.test"), RelationshipStatus.ACTIVE);
		pending(coach, "100% Fit", "fit_one@x.test");

		list(coach, "q", "%").andExpect(jsonPath("$.items[*].name").value(contains("100% Fit")));
		list(coach, "q", "_").andExpect(jsonPath("$.items[*].name").value(contains("100% Fit")));
		list(coach, "q", "\\").andExpect(jsonPath("$.totalItems").value(0));
	}

	@Test
	void paginatesOrderedByName() throws Exception {
		AppUser coach = coach("c@x.test");
		fixtures.link(coach, client("Elena", "E", "e@x.test"), RelationshipStatus.ACTIVE);
		fixtures.link(coach, client("alin", "A", "a@x.test"), RelationshipStatus.ACTIVE);
		pending(coach, "Cristi C", "c2@x.test");
		pending(coach, "Bogdan B", "b@x.test");
		fixtures.link(coach, client("Dana", "D", "d@x.test"), RelationshipStatus.PAUSED);

		list(coach, "size", "2").andExpect(jsonPath("$.items[*].name").value(contains("alin A", "Bogdan B")))
			.andExpect(jsonPath("$.totalItems").value(5))
			.andExpect(jsonPath("$.totalPages").value(3))
			.andExpect(jsonPath("$.size").value(2));
		list(coach, "size", "2", "page", "1").andExpect(jsonPath("$.items[*].name").value(contains("Cristi C", "Dana D")));
		list(coach, "size", "2", "page", "2").andExpect(jsonPath("$.items[*].name").value(contains("Elena E")));
		list(coach, "size", "2", "page", "9").andExpect(jsonPath("$.items.length()").value(0))
			.andExpect(jsonPath("$.totalItems").value(5))
			.andExpect(jsonPath("$.page").value(9));
	}

	@Test
	void emptyListHasZeroPages() throws Exception {
		list(coach("c@x.test")).andExpect(status().isOk())
			.andExpect(jsonPath("$.items.length()").value(0))
			.andExpect(jsonPath("$.totalItems").value(0))
			.andExpect(jsonPath("$.totalPages").value(0));
	}

	@Test
	void rejectsInvalidParameters() throws Exception {
		AppUser coach = coach("c@x.test");
		list(coach, "size", "0").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
			.andExpect(jsonPath("$.errors[0].field").value("size"))
			.andExpect(jsonPath("$.errors[0].code").value("MIN"));
		list(coach, "size", "101").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("MAX"));
		list(coach, "page", "-1").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].field").value("page"));
		list(coach, "q", "x".repeat(101)).andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("TOO_LONG"));
		list(coach, "status", "FOO").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("MALFORMED_REQUEST"));
		list(coach, "page", "x").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("MALFORMED_REQUEST"));
	}

	@Test
	void unverifiedCoachCanList() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.PENDING, "p@x.test");
		list(coach).andExpect(status().isOk()).andExpect(jsonPath("$.totalItems").value(0));
	}

}
