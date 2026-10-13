package com.anafitlab.backend.client;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
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

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.auth.util.TokenHasher;
import com.anafitlab.backend.client.entity.CoachInvite;
import com.anafitlab.backend.client.entity.InviteStatus;
import com.anafitlab.backend.client.repository.CoachInviteRepository;
import com.anafitlab.backend.client.service.InviteService;
import com.anafitlab.backend.client.util.InviteCodes;
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

	private int invitations;

	private Map<String, Object> createOk(AppUser coach) throws Exception {
		String email = "invitee" + (++invitations) + "@x.test";
		String body = mockMvc.perform(post("/api/v1/coach/clients").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach))
			.contentType(MediaType.APPLICATION_JSON)
			.content("{\"name\":\"Invitee\",\"email\":\"" + email + "\"}"))
			.andExpect(status().isCreated())
			.andReturn()
			.getResponse()
			.getContentAsString();
		return json.readValue(body, Map.class);
	}

	private ResultActions preview(String code) throws Exception {
		return mockMvc.perform(get("/api/v1/invites/{code}", code));
	}

	private ResultActions cancel(AppUser coach, Object id) throws Exception {
		return mockMvc.perform(delete("/api/v1/coach/invites/{id}", id).header(HttpHeaders.AUTHORIZATION,
				fixtures.bearer(coach)));
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
		cancel(coach, revoked.get("invitationId")).andExpect(status().isNoContent());
		preview((String) revoked.get("code")).andExpect(status().isGone())
			.andExpect(jsonPath("$.code").value("INVITE_REVOKED"));

		Map<String, Object> used = createOk(coach);
		jdbc.update("UPDATE coach_invite SET status = 'USED' WHERE id = ?::uuid", used.get("invitationId"));
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

	@Test
	void previewOfSuspendedCoachInviteIsUnavailable() throws Exception {
		AppUser coach = activeCoach("c@x.test");
		String code = (String) createOk(coach).get("code");
		jdbc.update("UPDATE app_user SET status = 'SUSPENDED' WHERE id = ?", coach.getId());

		preview(code).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("COACH_UNAVAILABLE"));
	}

}
