package com.anafitlab.backend.client;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;

import javax.sql.DataSource;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.auth.util.TokenHasher;
import com.anafitlab.backend.client.entity.CoachInvite;
import com.anafitlab.backend.client.entity.InviteStatus;
import com.anafitlab.backend.client.entity.RelationshipStatus;
import com.anafitlab.backend.client.repository.CoachInviteRepository;
import com.anafitlab.backend.client.service.InviteService;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.security.CurrentUser;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.MutableClock;
import com.anafitlab.backend.support.RowLockRace;
import com.anafitlab.backend.support.TestFixtures;
import tools.jackson.databind.json.JsonMapper;

class CoachInvitationActionsTest extends IntegrationTestBase {

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
	DataSource dataSource;

	private AppUser coach(String email) {
		return fixtures.user(Role.COACH, UserStatus.ACTIVE, email);
	}

	private ResultActions add(AppUser actor, String body) throws Exception {
		return mockMvc.perform(post("/api/v1/coach/clients").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(actor))
			.contentType(MediaType.APPLICATION_JSON)
			.content(body));
	}

	private ResultActions add(AppUser actor, String name, String email) throws Exception {
		return add(actor, json.writeValueAsString(Map.of("name", name, "email", email)));
	}

	@SuppressWarnings("unchecked")
	private Map<String, Object> addOk(AppUser coach, String name, String email) throws Exception {
		String body = add(coach, name, email).andExpect(status().isCreated()).andReturn().getResponse()
			.getContentAsString();
		return json.readValue(body, Map.class);
	}

	private ResultActions regenerate(AppUser actor, Object id) throws Exception {
		return mockMvc.perform(post("/api/v1/coach/invites/{id}/regenerate", id).header(HttpHeaders.AUTHORIZATION,
				fixtures.bearer(actor)));
	}

	@SuppressWarnings("unchecked")
	private Map<String, Object> regenerateOk(AppUser coach, Object id) throws Exception {
		String body = regenerate(coach, id).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
		return json.readValue(body, Map.class);
	}

	private ResultActions cancel(AppUser actor, Object id) throws Exception {
		return mockMvc.perform(delete("/api/v1/coach/invites/{id}", id).header(HttpHeaders.AUTHORIZATION,
				fixtures.bearer(actor)));
	}

	private ResultActions preview(Object code) throws Exception {
		return mockMvc.perform(get("/api/v1/invites/{code}", code));
	}

	private ResultActions list(AppUser coach) throws Exception {
		return mockMvc.perform(get("/api/v1/coach/clients").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach)));
	}

	private String storedStatus(Object id) {
		return jdbc.queryForObject("SELECT status FROM coach_invite WHERE id = ?::uuid", String.class, id.toString());
	}

	// --- add client ---

	@Test
	void addClientCreatesInvitationWithNameAndEmail() throws Exception {
		AppUser coach = coach("c@x.test");
		Map<String, Object> created = addOk(coach, "  Maria Pavel ", " Maria.Pavel@Mail.TEST ");

		String code = (String) created.get("code");
		assertThat(code).matches(CODE_PATTERN);
		assertThat(created.get("link")).isEqualTo("http://app.test/join/" + code);
		assertThat(created.get("name")).isEqualTo("Maria Pavel");
		assertThat(created.get("email")).isEqualTo("maria.pavel@mail.test");
		assertThat(created.get("expiresAt")).isEqualTo(clock.instant().plus(Duration.ofDays(7)).toString());
		Map<String, Object> row = jdbc.queryForMap("SELECT * FROM coach_invite WHERE id = ?::uuid",
				created.get("invitationId"));
		assertThat(row.get("label")).isEqualTo("Maria Pavel");
		assertThat(row.get("email")).isEqualTo("maria.pavel@mail.test");
		assertThat(row.get("status")).isEqualTo("PENDING");
		assertThat(row.get("code_hash")).isEqualTo(TokenHasher.sha256(code.replace("-", "")));

		list(coach).andExpect(jsonPath("$.items[0].id").value(created.get("invitationId")))
			.andExpect(jsonPath("$.items[0].status").value("INVITED"))
			.andExpect(jsonPath("$.items[0].name").value("Maria Pavel"));
		preview(code).andExpect(status().isOk());
	}

	@Test
	void addClientValidatesInput() throws Exception {
		AppUser coach = coach("c@x.test");
		add(coach, "{}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
			.andExpect(jsonPath("$.errors.length()").value(2));
		add(coach, " ", "a@x.test").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].field").value("name"))
			.andExpect(jsonPath("$.errors[0].code").value("REQUIRED"));
		add(coach, "x".repeat(101), "a@x.test").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("TOO_LONG"));
		add(coach, "Ana", "not-an-email").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].field").value("email"))
			.andExpect(jsonPath("$.errors[0].code").value("INVALID_EMAIL"));
		add(coach, "Ana", "a".repeat(60) + "@" + ("b".repeat(60) + ".").repeat(4) + "test")
			.andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors.length()").value(1))
			.andExpect(jsonPath("$.errors[0].code").value("TOO_LONG"));
		add(coach, "not json").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("MALFORMED_REQUEST"));
		assertThat(invites.count()).isZero();
	}

	@Test
	void addClientRejectsAPendingInvitationForTheSameEmail() throws Exception {
		AppUser coach = coach("c@x.test");
		Object first = addOk(coach, "Maria", "maria@x.test").get("invitationId");
		add(coach, "Maria again", "MARIA@x.test").andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("INVITE_ALREADY_PENDING"));

		clock.advance(Duration.ofDays(7).plusSeconds(1));
		Object second = addOk(coach, "Maria", "maria@x.test").get("invitationId");
		cancel(coach, second).andExpect(status().isNoContent());
		addOk(coach, "Maria", "maria@x.test");
		assertThat(storedStatus(first)).isEqualTo("PENDING");
	}

	@Test
	void addClientChecksOnlyTheCoachsOwnData() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser other = coach("o@x.test");
		addOk(other, "Maria", "maria@x.test");
		fixtures.link(other, fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "foreign@x.test"), RelationshipStatus.ACTIVE);

		addOk(coach, "Maria", "maria@x.test");
		addOk(coach, "Foreign", "foreign@x.test");
		addOk(coach, "Coach", "o@x.test");
	}

	@Test
	void addClientRejectsTheEmailOfACurrentClient() throws Exception {
		AppUser coach = coach("c@x.test");
		fixtures.link(coach, fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "a@x.test"), RelationshipStatus.ACTIVE);
		fixtures.link(coach, fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "p@x.test"), RelationshipStatus.PAUSED);
		fixtures.link(coach, fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "e@x.test"), RelationshipStatus.ENDED);

		add(coach, "Ana", "A@x.test").andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("ALREADY_YOUR_CLIENT"));
		add(coach, "Paul", "p@x.test").andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("ALREADY_YOUR_CLIENT"));
		addOk(coach, "Eve", "e@x.test");
	}

	@Test
	void onlyVerifiedCoachesCanAddClients() throws Exception {
		AppUser pendingCoach = fixtures.user(Role.COACH, UserStatus.PENDING, "p@x.test");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "cl@x.test");
		AppUser admin = fixtures.user(Role.ADMIN, UserStatus.ACTIVE, "ad@x.test");
		add(pendingCoach, "Ana", "a@x.test").andExpect(status().isForbidden())
			.andExpect(jsonPath("$.code").value("EMAIL_NOT_VERIFIED"));
		add(client, "Ana", "a@x.test").andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
		add(admin, "Ana", "a@x.test").andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
		mockMvc.perform(post("/api/v1/coach/clients").contentType(MediaType.APPLICATION_JSON)
			.content("{\"name\":\"Ana\",\"email\":\"a@x.test\"}")).andExpect(status().isUnauthorized());
		assertThat(invites.count()).isZero();
	}

	// --- regenerate ---

	@Test
	void regenerateReplacesTheCodeAndExtendsTheInvitation() throws Exception {
		AppUser coach = coach("c@x.test");
		Map<String, Object> created = addOk(coach, "Maria Pavel", "maria@x.test");
		Object id = created.get("invitationId");
		Instant createdAt = invites.findById(UUID.fromString((String) id)).orElseThrow().getCreatedAt();
		clock.advance(Duration.ofDays(3));

		Map<String, Object> renewed = regenerateOk(coach, id);

		assertThat(renewed.get("invitationId")).isEqualTo(id);
		assertThat(renewed.get("name")).isEqualTo("Maria Pavel");
		assertThat(renewed.get("email")).isEqualTo("maria@x.test");
		assertThat((String) renewed.get("code")).matches(CODE_PATTERN).isNotEqualTo(created.get("code"));
		assertThat(renewed.get("link")).isEqualTo("http://app.test/join/" + renewed.get("code"));
		assertThat(renewed.get("expiresAt")).isEqualTo(clock.instant().plus(Duration.ofDays(7)).toString());
		preview(created.get("code")).andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("INVITE_NOT_FOUND"));
		preview(renewed.get("code")).andExpect(status().isOk());
		CoachInvite stored = invites.findById(UUID.fromString((String) id)).orElseThrow();
		assertThat(stored.getCreatedAt()).isEqualTo(createdAt);
		assertThat(stored.getStatus()).isEqualTo(InviteStatus.PENDING);
		assertThat(invites.count()).isEqualTo(1);
	}

	@Test
	void regenerateRevivesAnExpiredInvitation() throws Exception {
		AppUser coach = coach("c@x.test");
		Object id = addOk(coach, "Maria", "maria@x.test").get("invitationId");
		clock.advance(Duration.ofDays(8));
		list(coach).andExpect(jsonPath("$.items[0].invitationExpired").value(true));

		Map<String, Object> renewed = regenerateOk(coach, id);

		preview(renewed.get("code")).andExpect(status().isOk());
		list(coach).andExpect(jsonPath("$.items[0].invitationExpired").value(false))
			.andExpect(jsonPath("$.items[0].invitationExpiresAt").value(renewed.get("expiresAt")));
	}

	@Test
	void regenerateIsLimitedToTheCoachsOwnPendingInvitations() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser other = coach("o@x.test");
		Map<String, Object> foreign = addOk(other, "Maria", "maria@x.test");

		regenerate(coach, foreign.get("invitationId")).andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("INVITE_NOT_FOUND"));
		preview(foreign.get("code")).andExpect(status().isOk());
		regenerate(coach, UUID.randomUUID()).andExpect(status().isNotFound());

		CoachInvite used = fixtures.invite(coach, "Uma", "u@x.test", InviteStatus.USED, clock.instant().plusSeconds(60));
		CoachInvite revoked = fixtures.invite(coach, "Rita", "r@x.test", InviteStatus.REVOKED,
				clock.instant().plusSeconds(60));
		regenerate(coach, used.getId()).andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("INVITE_NOT_PENDING"));
		regenerate(coach, revoked.getId()).andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("INVITE_NOT_PENDING"));
	}

	@Test
	void regenerateIsForVerifiedCoachesOnly() throws Exception {
		AppUser coach = coach("c@x.test");
		Object id = addOk(coach, "Maria", "maria@x.test").get("invitationId");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "cl@x.test");
		regenerate(client, id).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
		mockMvc.perform(post("/api/v1/coach/invites/{id}/regenerate", id)).andExpect(status().isUnauthorized());

		AppUser pendingCoach = fixtures.user(Role.COACH, UserStatus.PENDING, "p@x.test");
		CoachInvite legacy = fixtures.invite(pendingCoach, "Old", null, InviteStatus.PENDING,
				clock.instant().plusSeconds(60));
		regenerate(pendingCoach, legacy.getId()).andExpect(status().isForbidden())
			.andExpect(jsonPath("$.code").value("EMAIL_NOT_VERIFIED"));
	}

	@Test
	void regenerateRacingClaimKeepsTheUse() throws Exception {
		AppUser coach = coach("c@x.test");
		UUID id = UUID.fromString((String) addOk(coach, "Maria", "maria@x.test").get("invitationId"));
		String hashBefore = invites.findById(id).orElseThrow().getCodeHash();

		Throwable outcome = RowLockRace.run(dataSource, "SELECT 1 FROM coach_invite WHERE id = ? FOR UPDATE",
				"UPDATE coach_invite SET status = 'USED', used_at = now() WHERE id = ?", id,
				() -> inviteService.regenerate(new CurrentUser(coach.getId(), Role.COACH), id));

		assertThat(outcome).isInstanceOfSatisfying(ApiException.class,
				e -> assertThat(e.code()).isEqualTo("INVITE_NOT_PENDING"));
		CoachInvite stored = invites.findById(id).orElseThrow();
		assertThat(stored.getStatus()).isEqualTo(InviteStatus.USED);
		assertThat(stored.getCodeHash()).isEqualTo(hashBefore);
	}

	// --- cancel ---

	@Test
	void cancelRevokesAPendingInvitation() throws Exception {
		AppUser coach = coach("c@x.test");
		Map<String, Object> created = addOk(coach, "Maria", "maria@x.test");

		cancel(coach, created.get("invitationId")).andExpect(status().isNoContent());

		assertThat(storedStatus(created.get("invitationId"))).isEqualTo("REVOKED");
		preview(created.get("code")).andExpect(status().isGone()).andExpect(jsonPath("$.code").value("INVITE_REVOKED"));
		list(coach).andExpect(jsonPath("$.totalItems").value(0));
		cancel(coach, created.get("invitationId")).andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("INVITE_NOT_PENDING"));
	}

	@Test
	void cancelWorksOnExpiredInvitations() throws Exception {
		AppUser coach = coach("c@x.test");
		Object id = addOk(coach, "Maria", "maria@x.test").get("invitationId");
		clock.advance(Duration.ofDays(8));
		cancel(coach, id).andExpect(status().isNoContent());
		assertThat(storedStatus(id)).isEqualTo("REVOKED");
	}

	@Test
	void cancelIsLimitedToTheCoachsOwnPendingInvitations() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser other = coach("o@x.test");
		Map<String, Object> foreign = addOk(other, "Maria", "maria@x.test");

		cancel(coach, foreign.get("invitationId")).andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("INVITE_NOT_FOUND"));
		assertThat(storedStatus(foreign.get("invitationId"))).isEqualTo("PENDING");
		cancel(coach, UUID.randomUUID()).andExpect(status().isNotFound());

		CoachInvite used = fixtures.invite(coach, "Uma", "u@x.test", InviteStatus.USED, clock.instant().plusSeconds(60));
		cancel(coach, used.getId()).andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("INVITE_NOT_PENDING"));
		assertThat(storedStatus(used.getId())).isEqualTo("USED");
	}

	@Test
	void cancelIsForCoachesOnlyButAllowsUnverifiedOnes() throws Exception {
		AppUser coach = coach("c@x.test");
		Object id = addOk(coach, "Maria", "maria@x.test").get("invitationId");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "cl@x.test");
		AppUser admin = fixtures.user(Role.ADMIN, UserStatus.ACTIVE, "ad@x.test");
		cancel(client, id).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
		cancel(admin, id).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
		mockMvc.perform(delete("/api/v1/coach/invites/{id}", id)).andExpect(status().isUnauthorized());
		assertThat(storedStatus(id)).isEqualTo("PENDING");

		AppUser pendingCoach = fixtures.user(Role.COACH, UserStatus.PENDING, "p@x.test");
		CoachInvite legacy = fixtures.invite(pendingCoach, "Old", null, InviteStatus.PENDING,
				clock.instant().plusSeconds(60));
		cancel(pendingCoach, legacy.getId()).andExpect(status().isNoContent());
	}

	@Test
	void cancelRacingClaimKeepsTheUse() throws Exception {
		AppUser coach = coach("c@x.test");
		UUID id = UUID.fromString((String) addOk(coach, "Maria", "maria@x.test").get("invitationId"));

		Throwable outcome = RowLockRace.run(dataSource, "SELECT 1 FROM coach_invite WHERE id = ? FOR UPDATE",
				"UPDATE coach_invite SET status = 'USED', used_at = now() WHERE id = ?", id,
				() -> inviteService.cancel(new CurrentUser(coach.getId(), Role.COACH), id));

		assertThat(outcome).isInstanceOfSatisfying(ApiException.class,
				e -> assertThat(e.code()).isEqualTo("INVITE_NOT_PENDING"));
		assertThat(invites.findById(id).orElseThrow().getStatus()).isEqualTo(InviteStatus.USED);
	}

	// --- other coaches' clients ---

	@Test
	void coachCannotChangeAnotherCoachsClient() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser other = coach("o@x.test");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "cl@x.test");
		fixtures.link(other, client, RelationshipStatus.ACTIVE);

		mockMvc.perform(patch("/api/v1/coach/clients/{id}/relationship", client.getId())
			.header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach))
			.contentType(MediaType.APPLICATION_JSON)
			.content("{\"status\":\"ENDED\"}"))
			.andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("CLIENT_NOT_FOUND"));
		assertThat(jdbc.queryForObject("SELECT status FROM coach_client WHERE client_id = ?", String.class,
				client.getId())).isEqualTo("ACTIVE");
		list(coach).andExpect(jsonPath("$.totalItems").value(0));
	}

}
