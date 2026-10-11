package com.anafitlab.backend;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.jdbc.core.JdbcTemplate;

import com.anafitlab.backend.support.IntegrationTestBase;

class SchemaConstraintsTest extends IntegrationTestBase {

	@Autowired
	JdbcTemplate jdbc;

	private UUID insertUser(String email, String role) {
		UUID id = UUID.randomUUID();
		jdbc.update("""
				INSERT INTO app_user (id, email, password_hash, role, first_name, last_name, locale, timezone, status)
				VALUES (?, ?, 'hash', ?, 'A', 'B', 'en', 'Europe/Bucharest', 'ACTIVE')
				""", id, email, role);
		return id;
	}

	private void insertLink(UUID coach, UUID client, String status) {
		jdbc.update("INSERT INTO coach_client (coach_id, client_id, status) VALUES (?, ?, ?)", coach, client, status);
	}

	private void insertInvite(UUID coach, String codeHash) {
		jdbc.update("""
				INSERT INTO coach_invite (coach_id, code_hash, status, expires_at)
				VALUES (?, ?, 'PENDING', now() + interval '7 days')
				""", coach, codeHash);
	}

	@Test
	void rejectsUppercaseEmail() {
		assertThatThrownBy(() -> insertUser("Ana@x.ro", "CLIENT")).isInstanceOf(DataIntegrityViolationException.class);
	}

	@Test
	void rejectsDuplicateEmail() {
		insertUser("ana@x.ro", "CLIENT");
		assertThatThrownBy(() -> insertUser("ana@x.ro", "COACH")).isInstanceOf(DataIntegrityViolationException.class);
	}

	@Test
	void allowsOnlyOneCurrentCoachPerClient() {
		UUID coach1 = insertUser("c1@x.ro", "COACH");
		UUID coach2 = insertUser("c2@x.ro", "COACH");
		UUID client = insertUser("cl@x.ro", "CLIENT");
		insertLink(coach1, client, "ENDED");
		insertLink(coach1, client, "ACTIVE");
		assertThatThrownBy(() -> insertLink(coach2, client, "ACTIVE")).isInstanceOf(DataIntegrityViolationException.class);
		assertThatThrownBy(() -> insertLink(coach2, client, "PAUSED")).isInstanceOf(DataIntegrityViolationException.class);
	}

	@Test
	void rejectsInvitedStatus() {
		UUID coach = insertUser("c1@x.ro", "COACH");
		UUID client = insertUser("cl@x.ro", "CLIENT");
		assertThatThrownBy(() -> insertLink(coach, client, "INVITED")).isInstanceOf(DataIntegrityViolationException.class);
	}

	@Test
	void rejectsDuplicateInviteCodeHash() {
		UUID coach = insertUser("c1@x.ro", "COACH");
		insertInvite(coach, "abc");
		assertThatThrownBy(() -> insertInvite(coach, "abc")).isInstanceOf(DataIntegrityViolationException.class);
	}

	@Test
	void deletingUserCascadesTokensAndNullsInviteUsage() {
		UUID coach = insertUser("c1@x.ro", "COACH");
		UUID client = insertUser("cl@x.ro", "CLIENT");
		insertInvite(coach, "abc");
		jdbc.update("UPDATE coach_invite SET status = 'USED', used_by_client_id = ?", client);
		jdbc.update("""
				INSERT INTO refresh_token (user_id, token_hash, family_id, expires_at)
				VALUES (?, 'rt', ?, now() + interval '30 days')
				""", client, UUID.randomUUID());
		jdbc.update("""
				INSERT INTO user_action_token (user_id, purpose, token_hash, expires_at)
				VALUES (?, 'PASSWORD_RESET', 'at', now() + interval '1 hour')
				""", client);

		jdbc.update("DELETE FROM app_user WHERE id = ?", client);

		assertThat(jdbc.queryForObject("SELECT count(*) FROM refresh_token", Integer.class)).isZero();
		assertThat(jdbc.queryForObject("SELECT count(*) FROM user_action_token", Integer.class)).isZero();
		assertThat(jdbc.queryForObject("SELECT used_by_client_id FROM coach_invite", UUID.class)).isNull();
	}

}
