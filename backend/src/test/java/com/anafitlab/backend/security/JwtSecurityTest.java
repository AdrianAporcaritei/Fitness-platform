package com.anafitlab.backend.security;

import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.UUID;

import javax.crypto.spec.SecretKeySpec;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.test.web.servlet.MockMvc;

import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.Role;
import com.anafitlab.backend.auth.UserStatus;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.MutableClock;
import com.anafitlab.backend.support.TestFixtures;
import com.nimbusds.jose.jwk.source.ImmutableSecret;

class JwtSecurityTest extends IntegrationTestBase {

	@Autowired
	MockMvc mockMvc;

	@Autowired
	TestFixtures fixtures;

	@Autowired
	MutableClock clock;

	@Autowired
	MessageSource messages;

	@Test
	void meReturnsCurrentUser() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		mockMvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach)))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.id").value(coach.getId().toString()))
				.andExpect(jsonPath("$.role").value("COACH"))
				.andExpect(jsonPath("$.email").value("coach@x.test"))
				.andExpect(jsonPath("$.status").value("ACTIVE"))
				.andExpect(jsonPath("$.locale").value("en"))
				.andExpect(jsonPath("$.passwordHash").doesNotExist());
	}

	@Test
	void missingTokenIs401Problem() throws Exception {
		mockMvc.perform(get("/api/v1/me"))
				.andExpect(status().isUnauthorized())
				.andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
				.andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
	}

	@Test
	void garbageTokenIs401Problem() throws Exception {
		mockMvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, "Bearer abc.def.ghi"))
				.andExpect(status().isUnauthorized())
				.andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
				.andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
	}

	@Test
	void tokenSignedWithOtherSecretIs401() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		String token = tokenSignedWith("another-secret-of-at-least-32-bytes!!", MacAlgorithm.HS256, coach);
		mockMvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
	}

	@Test
	void onlyHs256IsAccepted() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		String secret = "test-only-jwt-secret-0123456789abcdef0123456789abcdef-xxxxxxxxxx";
		String token = tokenSignedWith(secret, MacAlgorithm.HS512, coach);
		mockMvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
				.andExpect(status().isUnauthorized());
	}

	@Test
	void expiredTokenIs401() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		String bearer = fixtures.bearer(coach);
		mockMvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, bearer)).andExpect(status().isOk());
		clock.advance(Duration.ofMinutes(16));
		mockMvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, bearer))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
	}

	@Test
	void tokenOfDeletedUserIs401() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		String bearer = fixtures.bearer(coach);
		fixtures.delete(coach);
		mockMvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, bearer))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
	}

	@Test
	void clientOnCoachRouteIs403Problem() throws Exception {
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "client@x.test");
		mockMvc.perform(get("/api/v1/coach/profile").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(client)))
				.andExpect(status().isForbidden())
				.andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
				.andExpect(jsonPath("$.code").value("FORBIDDEN"));
	}

	@Test
	void detailUsesUserLocale() throws Exception {
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "client@x.test");
		fixtures.setLocale(client, "ro");
		String ro = messages.getMessage("error.FORBIDDEN", null, java.util.Locale.forLanguageTag("ro"));
		mockMvc.perform(get("/api/v1/coach/profile").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(client))
				.header(HttpHeaders.ACCEPT_LANGUAGE, "en"))
				.andExpect(status().isForbidden())
				.andExpect(jsonPath("$.detail").value(ro));
	}

	@Test
	void docsStayPublic() throws Exception {
		mockMvc.perform(get("/openapi.yaml")).andExpect(status().isOk());
		mockMvc.perform(get("/v3/api-docs")).andExpect(status().isOk());
		mockMvc.perform(get("/swagger-ui/index.html")).andExpect(status().isOk());
	}

	@Test
	void corsAllowsConfiguredOrigin() throws Exception {
		mockMvc.perform(options("/api/v1/me").header(HttpHeaders.ORIGIN, "http://app.test")
				.header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "GET")
				.header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, "authorization"))
				.andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://app.test"));
		mockMvc.perform(options("/api/v1/me").header(HttpHeaders.ORIGIN, "http://evil.test")
				.header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "GET"))
				.andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, nullValue()));
	}

	private String tokenSignedWith(String secret, MacAlgorithm algorithm, AppUser user) {
		var key = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
		var encoder = new NimbusJwtEncoder(new ImmutableSecret<>(key));
		JwtClaimsSet claims = JwtClaimsSet.builder().subject(user.getId().toString()).claim("role", "COACH")
				.id(UUID.randomUUID().toString()).issuedAt(clock.instant())
				.expiresAt(clock.instant().plus(Duration.ofMinutes(15))).build();
		return encoder.encode(JwtEncoderParameters.from(JwsHeader.with(algorithm).build(), claims)).getTokenValue();
	}

}
