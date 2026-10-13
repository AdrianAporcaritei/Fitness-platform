package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.sql.Timestamp;
import java.time.Duration;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.MutableClock;
import com.anafitlab.backend.support.RecordingEmailSender;
import com.anafitlab.backend.support.TestFixtures;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

class PasswordResetTest extends IntegrationTestBase {

	private static final String EMAIL = "coach@x.test";
	private static final String NEW_PASSWORD = "brand-new-pass-9";

	@Autowired
	MockMvc mockMvc;

	@Autowired
	TestFixtures fixtures;

	@Autowired
	MutableClock clock;

	@Autowired
	JdbcTemplate jdbc;

	@Autowired
	JsonMapper json;

	@Autowired
	RecordingEmailSender emails;

	private ResultActions postJson(String path, Map<String, String> body) throws Exception {
		return mockMvc.perform(post("/api/v1" + path).contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(body)));
	}

	private ResultActions requestReset(String email) throws Exception {
		return postJson("/auth/password-reset/request", Map.of("email", email));
	}

	private ResultActions confirm(String token, String password) throws Exception {
		return postJson("/auth/password-reset/confirm", Map.of("token", token, "newPassword", password));
	}

	private ResultActions login(String email, String password) throws Exception {
		return postJson("/auth/login", Map.of("email", email, "password", password));
	}

	private ResultActions refresh(String token) throws Exception {
		return postJson("/auth/refresh", Map.of("refreshToken", token));
	}

	private JsonNode session(String email) throws Exception {
		return json.readTree(login(email, TestFixtures.PASSWORD).andExpect(status().isOk()).andReturn().getResponse()
				.getContentAsString());
	}

	private ResultActions changePassword(JsonNode session, String current, String next, String refreshToken)
			throws Exception {
		return mockMvc.perform(post("/api/v1/me/password").contentType(MediaType.APPLICATION_JSON)
				.header("Authorization", "Bearer " + session.get("accessToken").asString())
				.content(json.writeValueAsString(
						Map.of("currentPassword", current, "newPassword", next, "refreshToken", refreshToken))));
	}

	private String resetToken(String email) {
		return emails.extractToken(emails.lastTo(email));
	}

	private int liveFamilies(String email) {
		return jdbc.queryForObject("""
				SELECT count(DISTINCT family_id) FROM refresh_token t JOIN app_user u ON u.id = t.user_id
				WHERE u.email = ? AND t.revoked_at IS NULL AND t.replaced_by_id IS NULL""", Integer.class, email);
	}

	@Test
	void requestAlways202() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		requestReset(EMAIL).andExpect(status().isAccepted()).andExpect(content().string(""));
		requestReset("nobody@x.test").andExpect(status().isAccepted()).andExpect(content().string(""));
		assertThat(emails.lastTo(EMAIL)).isNotNull();
		assertThat(emails.lastTo("nobody@x.test")).isNull();
		assertThat(emails.sent()).hasSize(1);
	}

	@Test
	void requestNormalizesEmail() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		requestReset("  Coach@X.test ").andExpect(status().isAccepted());
		assertThat(emails.lastTo(EMAIL)).isNotNull();
	}

	@Test
	void requestRejectsBlankAndInvalidEmail() throws Exception {
		requestReset(" ").andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='email')].code").value(hasItem("REQUIRED")));
		requestReset("not-an-email").andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='email')].code").value(hasItem("INVALID_EMAIL")));
	}

	@Test
	void noEmailForSuspended() throws Exception {
		fixtures.user(Role.COACH, UserStatus.SUSPENDED, EMAIL);
		requestReset(EMAIL).andExpect(status().isAccepted()).andExpect(content().string(""));
		assertThat(emails.sent()).isEmpty();
	}

	@Test
	void confirmSetsPasswordAndRevokesSessions() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		String r = session(EMAIL).get("refreshToken").asString();
		requestReset(EMAIL).andExpect(status().isAccepted());
		String body = confirm(resetToken(EMAIL), NEW_PASSWORD).andExpect(status().isOk())
				.andExpect(jsonPath("$.user.email").value(EMAIL)).andReturn().getResponse().getContentAsString();
		login(EMAIL, NEW_PASSWORD).andExpect(status().isOk());
		login(EMAIL, TestFixtures.PASSWORD).andExpect(status().isUnauthorized());
		refresh(r).andExpect(status().isUnauthorized());
		// the session returned by confirm works and is the only live family besides the new login
		assertThat(liveFamilies(EMAIL)).isEqualTo(2);
		refresh(json.readTree(body).get("refreshToken").asString()).andExpect(status().isOk());
	}

	@Test
	void confirmTokenIsSingleUse() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		requestReset(EMAIL);
		String token = resetToken(EMAIL);
		confirm(token, NEW_PASSWORD).andExpect(status().isOk());
		confirm(token, "another-pass-77").andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("INVALID_TOKEN"));
	}

	@Test
	void confirmVerifiesPendingUser() throws Exception {
		fixtures.user(Role.COACH, UserStatus.PENDING, EMAIL);
		requestReset(EMAIL);
		confirm(resetToken(EMAIL), NEW_PASSWORD).andExpect(status().isOk())
				.andExpect(jsonPath("$.user.status").value("ACTIVE"));
		assertThat(jdbc.queryForObject("SELECT email_verified_at FROM app_user WHERE email = ?",
				Timestamp.class, EMAIL)).isNotNull();
		login(EMAIL, NEW_PASSWORD).andExpect(status().isOk()).andExpect(jsonPath("$.user.status").value("ACTIVE"));
	}

	@Test
	void resetTokenExpiresAfterOneHour() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		requestReset(EMAIL);
		String token = resetToken(EMAIL);
		clock.advance(Duration.ofHours(1).plusSeconds(1));
		confirm(token, NEW_PASSWORD).andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("INVALID_TOKEN"));
	}

	@Test
	void newerRequestInvalidatesOlderToken() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		requestReset(EMAIL);
		String old = resetToken(EMAIL);
		requestReset(EMAIL);
		confirm(old, NEW_PASSWORD).andExpect(status().isBadRequest());
		confirm(resetToken(EMAIL), NEW_PASSWORD).andExpect(status().isOk());
	}

	@Test
	void confirmEnforcesPasswordPolicy() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		requestReset(EMAIL);
		String token = resetToken(EMAIL);
		confirm(token, "short").andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='newPassword')].code").value(hasItem("PASSWORD_POLICY")));
		// a rejected request does not burn the token
		confirm(token, NEW_PASSWORD).andExpect(status().isOk());
	}

	@Test
	void confirmRejectsSuspendedUser() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		requestReset(EMAIL);
		jdbc.update("UPDATE app_user SET status = 'SUSPENDED' WHERE email = ?", EMAIL);
		confirm(resetToken(EMAIL), NEW_PASSWORD).andExpect(status().isForbidden())
				.andExpect(jsonPath("$.code").value("ACCOUNT_SUSPENDED"));
		assertThat(jdbc.queryForObject("""
				SELECT t.used_at FROM user_action_token t JOIN app_user u ON u.id = t.user_id
				WHERE u.email = ? AND t.purpose = 'PASSWORD_RESET'""", Timestamp.class, EMAIL)).isNull();
		// old password still current: login gets past the credential check and hits the suspended check
		login(EMAIL, TestFixtures.PASSWORD).andExpect(status().isForbidden());
		login(EMAIL, NEW_PASSWORD).andExpect(status().isUnauthorized());
	}

	@Test
	void resetRequestRateLimitedPerEmail() throws Exception {
		for (int i = 0; i < 3; i++) {
			requestReset("any@x.test").andExpect(status().isAccepted());
		}
		requestReset("any@x.test").andExpect(status().isTooManyRequests());
		requestReset("ANY@x.test ").andExpect(status().isTooManyRequests());
		requestReset("other@x.test").andExpect(status().isAccepted());
	}

	@Test
	void resetRequestRateLimitedPerIp() throws Exception {
		for (int i = 0; i < 10; i++) {
			requestReset("user" + i + "@x.test").andExpect(status().isAccepted());
		}
		requestReset("user10@x.test").andExpect(status().isTooManyRequests());
	}

	@Test
	void wrongCurrentPasswordsAreRateLimitedAndShareLoginBudget() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		JsonNode a = session(EMAIL);
		for (int i = 0; i < 5; i++) {
			changePassword(a, "wrong-password-1", NEW_PASSWORD, a.get("refreshToken").asString())
					.andExpect(status().isBadRequest())
					.andExpect(jsonPath("$.code").value("INVALID_CURRENT_PASSWORD"));
		}
		changePassword(a, TestFixtures.PASSWORD, NEW_PASSWORD, a.get("refreshToken").asString())
				.andExpect(status().isTooManyRequests()).andExpect(header().exists("Retry-After"));
		// same bucket as login: the failures above block login for this email too
		login(EMAIL, TestFixtures.PASSWORD).andExpect(status().isTooManyRequests());
	}

	@Test
	void changePasswordKeepsCurrentSessionOnly() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		JsonNode a = session(EMAIL);
		JsonNode b = session(EMAIL);
		changePassword(a, TestFixtures.PASSWORD, NEW_PASSWORD, a.get("refreshToken").asString())
				.andExpect(status().isNoContent());
		login(EMAIL, NEW_PASSWORD).andExpect(status().isOk());
		login(EMAIL, TestFixtures.PASSWORD).andExpect(status().isUnauthorized());
		refresh(a.get("refreshToken").asString()).andExpect(status().isOk());
		refresh(b.get("refreshToken").asString()).andExpect(status().isUnauthorized());
	}

	@Test
	void changePasswordWrongCurrent() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		JsonNode a = session(EMAIL);
		changePassword(a, "wrong-password-1", NEW_PASSWORD, a.get("refreshToken").asString())
				.andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("INVALID_CURRENT_PASSWORD"));
		login(EMAIL, TestFixtures.PASSWORD).andExpect(status().isOk());
		assertThat(liveFamilies(EMAIL)).isEqualTo(2);
	}

	@Test
	void changePasswordValidates() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		JsonNode a = session(EMAIL);
		changePassword(a, TestFixtures.PASSWORD, "short", a.get("refreshToken").asString())
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='newPassword')].code").value(hasItem("PASSWORD_POLICY")));
		changePassword(a, TestFixtures.PASSWORD, NEW_PASSWORD, " ").andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='refreshToken')].code").value(hasItem("REQUIRED")));
	}

	@Test
	void changePasswordRequiresAuthentication() throws Exception {
		postJson("/me/password", Map.of("currentPassword", "x", "newPassword", NEW_PASSWORD, "refreshToken", "r"))
				.andExpect(status().isUnauthorized());
	}

	@Test
	void unknownRefreshTokenRevokesAllFamilies() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		JsonNode a = session(EMAIL);
		JsonNode b = session(EMAIL);
		changePassword(a, TestFixtures.PASSWORD, NEW_PASSWORD, "not-a-real-token").andExpect(status().isNoContent());
		assertThat(liveFamilies(EMAIL)).isZero();
		refresh(a.get("refreshToken").asString()).andExpect(status().isUnauthorized());
		refresh(b.get("refreshToken").asString()).andExpect(status().isUnauthorized());
		login(EMAIL, NEW_PASSWORD).andExpect(status().isOk());
	}

	@Test
	void anotherUsersRefreshTokenRevokesAllOfCallersFamilies() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, EMAIL);
		fixtures.user(Role.COACH, UserStatus.ACTIVE, "other@x.test");
		JsonNode a = session(EMAIL);
		JsonNode b = session(EMAIL);
		JsonNode other = session("other@x.test");
		changePassword(a, TestFixtures.PASSWORD, NEW_PASSWORD, other.get("refreshToken").asString())
				.andExpect(status().isNoContent());
		assertThat(liveFamilies(EMAIL)).isZero();
		refresh(a.get("refreshToken").asString()).andExpect(status().isUnauthorized());
		refresh(b.get("refreshToken").asString()).andExpect(status().isUnauthorized());
		assertThat(liveFamilies("other@x.test")).isEqualTo(1);
		refresh(other.get("refreshToken").asString()).andExpect(status().isOk());
	}

}
