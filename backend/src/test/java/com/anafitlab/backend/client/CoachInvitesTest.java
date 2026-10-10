package com.anafitlab.backend.client;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.hamcrest.Matchers.hasKey;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Duration;
import java.util.Map;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.support.TransactionTemplate;

import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.Role;
import com.anafitlab.backend.auth.TokenHasher;
import com.anafitlab.backend.auth.UserStatus;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.MutableClock;
import com.anafitlab.backend.support.TestFixtures;
import tools.jackson.databind.json.JsonMapper;

class CoachInvitesTest extends IntegrationTestBase {

	private static final String CODE_PATTERN = "^[0-9A-HJKMNP-TV-Z]{5}-[0-9A-HJKMNP-TV-Z]{5}$";

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
	CoachInviteRepository invites;

	@Autowired
	InviteService inviteService;

	@Autowired
	TransactionTemplate tx;

	private AppUser activeCoach(String email) {
		return fixtures.user(Role.COACH, UserStatus.ACTIVE, email);
	}

	private ResultActions create(AppUser coach) throws Exception {
		return mockMvc.perform(post("/api/v1/coach/invites").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach)));
	}

	private Map<String, Object> createOk(AppUser coach) throws Exception {
		String body = create(coach).andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
		return json.readValue(body, Map.class);
	}

	private ResultActions preview(String code) throws Exception {
		return mockMvc.perform(get("/api/v1/invites/{code}", code));
	}

	private ResultActions revoke(AppUser coach, Object id) throws Exception {
		return mockMvc.perform(post("/api/v1/coach/invites/{id}/revoke", id).header(HttpHeaders.AUTHORIZATION,
				fixtures.bearer(coach)));
	}

	@Test
	void activeCoachCreatesInvite() throws Exception {
		AppUser coach = activeCoach("c@x.test");
		Map<String, Object> created = createOk(coach);
		String code = (String) created.get("code");
		assertThat(code).matches(CODE_PATTERN);
		assertThat(created.get("link")).isEqualTo("http://app.test/join/" + code);
		assertThat(created.get("expiresAt")).isEqualTo(clock.instant().plus(Duration.ofDays(7)).toString());
		String hash = jdbc.queryForObject("SELECT code_hash FROM coach_invite WHERE id = ?::uuid", String.class,
				created.get("id"));
		assertThat(hash).isNotEqualTo(code).isEqualTo(TokenHasher.sha256(code.replace("-", "")));
	}

	@Test
	void createAcceptsLabelAndRejectsTooLong() throws Exception {
		AppUser coach = activeCoach("c@x.test");
		mockMvc.perform(post("/api/v1/coach/invites").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach))
				.contentType(MediaType.APPLICATION_JSON).content("{\"label\":\"Maria\"}"))
			.andExpect(status().isCreated())
			.andExpect(jsonPath("$.label").value("Maria"));
		mockMvc.perform(post("/api/v1/coach/invites").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach))
				.contentType(MediaType.APPLICATION_JSON).content("{\"label\":\"" + "x".repeat(101) + "\"}"))
			.andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("TOO_LONG"));
	}

	@Test
	void pendingCoachCannotCreateInvite() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.PENDING, "p@x.test");
		create(coach).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("EMAIL_NOT_VERIFIED"));
	}

	@Test
	void clientCannotCreateInvite() throws Exception {
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "cl@x.test");
		create(client).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
	}

	@Test
	void listShowsDerivedStatusWithoutCode() throws Exception {
		AppUser coach = activeCoach("c@x.test");
		createOk(coach);
		clock.advance(Duration.ofDays(7).plusSeconds(1));
		Thread.sleep(5);
		createOk(coach);
		Thread.sleep(5);
		Object revokedId = createOk(coach).get("id");
		revoke(coach, revokedId).andExpect(status().isNoContent());

		mockMvc.perform(get("/api/v1/coach/invites").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach)))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.length()").value(3))
			.andExpect(jsonPath("$[0].status").value("REVOKED"))
			.andExpect(jsonPath("$[1].status").value("PENDING"))
			.andExpect(jsonPath("$[2].status").value("EXPIRED"))
			.andExpect(jsonPath("$[0]", not(hasKey("code"))))
			.andExpect(jsonPath("$[0]", not(hasKey("codeHash"))));
	}

	@Test
	void revokePendingOnly() throws Exception {
		AppUser coach = activeCoach("c@x.test");
		AppUser other = activeCoach("o@x.test");
		Object id = createOk(coach).get("id");
		revoke(other, id).andExpect(status().isNotFound()).andExpect(jsonPath("$.code").value("INVITE_NOT_FOUND"));
		revoke(coach, UUID.randomUUID()).andExpect(status().isNotFound());
		revoke(coach, id).andExpect(status().isNoContent());
		revoke(coach, id).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("INVITE_NOT_REVOCABLE"));
	}

	@Test
	void expiredInviteIsNotRevocable() throws Exception {
		AppUser coach = activeCoach("c@x.test");
		Object id = createOk(coach).get("id");
		clock.advance(Duration.ofDays(7).plusSeconds(1));
		revoke(coach, id).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("INVITE_NOT_REVOCABLE"));
	}

	@Test
	void previewReturnsCoachName() throws Exception {
		AppUser coach = activeCoach("c@x.test");
		String code = (String) createOk(coach).get("code");
		preview(code).andExpect(status().isOk())
			.andExpect(jsonPath("$.coachFirstName").value("Test"))
			.andExpect(jsonPath("$.coachLastName").value("COACH"))
			.andExpect(jsonPath("$.valid").value(true));
	}

	@Test
	void previewAcceptsLooselyTypedCode() throws Exception {
		AppUser coach = activeCoach("c@x.test");
		String issued = (String) createOk(coach).get("code");
		preview(issued.toLowerCase()).andExpect(status().isOk());
		preview(issued.replace("-", "")).andExpect(status().isOk());
		preview(" " + issued.substring(0, 3) + " " + issued.substring(3) + " ").andExpect(status().isOk());

		CoachInvite fixed = new CoachInvite();
		fixed.setCoachId(coach.getId());
		fixed.setCodeHash(TokenHasher.sha256("01ABCDEFGH"));
		fixed.setStatus(InviteStatus.PENDING);
		fixed.setExpiresAt(clock.instant().plus(Duration.ofDays(1)));
		invites.save(fixed);
		preview("OlABC-DEFGH").andExpect(status().isOk());
		preview("o1abcdefgh").andExpect(status().isOk());
	}

	@Test
	void previewErrors() throws Exception {
		AppUser coach = activeCoach("c@x.test");
		preview("ZZZZZ-ZZZZZ").andExpect(status().isNotFound()).andExpect(jsonPath("$.code").value("INVITE_NOT_FOUND"));
		preview("---").andExpect(status().isNotFound()).andExpect(jsonPath("$.code").value("INVITE_NOT_FOUND"));
		preview("   ").andExpect(status().isNotFound()).andExpect(jsonPath("$.code").value("INVITE_NOT_FOUND"));

		Map<String, Object> revoked = createOk(coach);
		revoke(coach, revoked.get("id")).andExpect(status().isNoContent());
		preview((String) revoked.get("code")).andExpect(status().isGone())
			.andExpect(jsonPath("$.code").value("INVITE_REVOKED"));

		Map<String, Object> used = createOk(coach);
		jdbc.update("UPDATE coach_invite SET status = 'USED' WHERE id = ?::uuid", used.get("id"));
		preview((String) used.get("code")).andExpect(status().isGone())
			.andExpect(jsonPath("$.code").value("INVITE_USED"));

		String expired = (String) createOk(coach).get("code");
		clock.advance(Duration.ofDays(7).plusSeconds(1));
		preview(expired).andExpect(status().isGone()).andExpect(jsonPath("$.code").value("INVITE_EXPIRED"));
	}

	@Test
	void previewRateLimited() throws Exception {
		for (int i = 0; i < 20; i++) {
			preview("ZZZZZ-ZZZZZ").andExpect(status().isNotFound());
		}
		preview("ZZZZZ-ZZZZZ").andExpect(status().isTooManyRequests()).andExpect(header().exists("Retry-After"));
	}

	@Test
	void claimAndMarkUsedWithinTransaction() {
		AppUser coach = activeCoach("c@x.test");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "cl@x.test");
		String code = InviteCodes.display("01ABCDEFGH");
		CoachInvite invite = new CoachInvite();
		invite.setCoachId(coach.getId());
		invite.setCodeHash(TokenHasher.sha256("01ABCDEFGH"));
		invite.setStatus(InviteStatus.PENDING);
		invite.setExpiresAt(clock.instant().plus(Duration.ofDays(1)));
		UUID id = invites.save(invite).getId();

		tx.executeWithoutResult(s -> {
			CoachInvite claimed = inviteService.claim(code.toLowerCase());
			assertThat(claimed.getId()).isEqualTo(id);
			inviteService.markUsed(claimed, client.getId());
		});

		CoachInvite stored = invites.findById(id).orElseThrow();
		assertThat(stored.getStatus()).isEqualTo(InviteStatus.USED);
		assertThat(stored.getUsedAt()).isEqualTo(clock.instant());
		assertThat(stored.getUsedByClientId()).isEqualTo(client.getId());
		assertThat(assertThrows(ApiException.class,
				() -> tx.executeWithoutResult(s -> inviteService.claim(code))).code()).isEqualTo("INVITE_USED");
		assertThat(assertThrows(ApiException.class,
				() -> tx.executeWithoutResult(s -> inviteService.claim("  ")))
			.code()).isEqualTo("INVITE_NOT_FOUND");
	}

}
