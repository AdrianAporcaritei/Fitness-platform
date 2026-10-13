package com.anafitlab.backend.common.error;

import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Locale;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.TestFixtures;

class ErrorFormatTest extends IntegrationTestBase {

	@Autowired
	TestFixtures fixtures;

	private String authorization;

	@BeforeEach
	void signIn() {
		authorization = fixtures.bearer(fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "client@x.test"));
	}

	private MockHttpServletRequestBuilder get(String url) {
		return MockMvcRequestBuilders.get(url).header(HttpHeaders.AUTHORIZATION, authorization);
	}

	private MockHttpServletRequestBuilder post(String url) {
		return MockMvcRequestBuilders.post(url).header(HttpHeaders.AUTHORIZATION, authorization);
	}

	@Autowired
	MockMvc mockMvc;

	@Autowired
	MessageSource messages;

	@Test
	void apiExceptionBecomesProblemDetail() throws Exception {
		mockMvc.perform(get("/api/v1/test/api-error"))
				.andExpect(status().isConflict())
				.andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
				.andExpect(jsonPath("$.code").value("EMAIL_TAKEN"))
				.andExpect(jsonPath("$.status").value(409));
	}

	@Test
	void detailIsLocalizedRomanian() throws Exception {
		String ro = messages.getMessage("error.EMAIL_TAKEN", null, Locale.forLanguageTag("ro"));
		String en = messages.getMessage("error.EMAIL_TAKEN", null, Locale.ENGLISH);
		AppUser romanian = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "ro@x.test");
		fixtures.setLocale(romanian, "ro");
		// the signed-in user's locale wins over Accept-Language
		mockMvc.perform(MockMvcRequestBuilders.get("/api/v1/test/api-error")
				.header(HttpHeaders.AUTHORIZATION, fixtures.bearer(romanian))
				.header("Accept-Language", "en"))
				.andExpect(jsonPath("$.detail").value(ro));
		mockMvc.perform(get("/api/v1/test/api-error").header("Accept-Language", "ro"))
				.andExpect(jsonPath("$.detail").value(en));
		assertNotEquals(ro, en);
	}

	@Test
	void validationErrorsListFieldCodes() throws Exception {
		mockMvc.perform(post("/api/v1/test/validate").contentType(MediaType.APPLICATION_JSON).content("{}"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
				.andExpect(jsonPath("$.errors[0].field").value("name"))
				.andExpect(jsonPath("$.errors[0].code").value("REQUIRED"));
	}

	@Test
	void malformedJsonIs400() throws Exception {
		mockMvc.perform(post("/api/v1/test/validate").contentType(MediaType.APPLICATION_JSON).content("{"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("MALFORMED_REQUEST"));
	}

	@Test
	void rateLimitedSetsRetryAfter() throws Exception {
		mockMvc.perform(get("/api/v1/test/rate-limited"))
				.andExpect(status().isTooManyRequests())
				.andExpect(header().string("Retry-After", "90"))
				.andExpect(jsonPath("$.code").value("RATE_LIMITED"));
	}

	@Test
	void unknownRouteIs404Problem() throws Exception {
		mockMvc.perform(get("/api/v1/nope"))
				.andExpect(status().isNotFound())
				.andExpect(jsonPath("$.code").value("NOT_FOUND"));
	}

	@Test
	void unhandledExceptionIs500WithoutLeakingDetails() throws Exception {
		mockMvc.perform(get("/api/v1/test/boom"))
				.andExpect(status().isInternalServerError())
				.andExpect(jsonPath("$.code").value("INTERNAL_ERROR"))
				.andExpect(content().string(not(containsString("secret internal detail"))));
	}

	@Test
	void accessDeniedIs403Forbidden() throws Exception {
		mockMvc.perform(get("/api/v1/test/forbidden")).andExpect(status().isForbidden())
				.andExpect(jsonPath("$.code").value("FORBIDDEN"));
	}

	@Test
	void authenticationExceptionIs401Unauthorized() throws Exception {
		mockMvc.perform(get("/api/v1/test/unauthorized")).andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
	}

	@Test
	void wrongMethodIs405WithCode() throws Exception {
		mockMvc.perform(post("/api/v1/test/api-error")).andExpect(status().isMethodNotAllowed())
				.andExpect(jsonPath("$.code").value("METHOD_NOT_ALLOWED"))
				.andExpect(header().exists("Allow"));
	}

	@Test
	void wrongContentTypeIs415WithCode() throws Exception {
		mockMvc.perform(post("/api/v1/test/validate").contentType(MediaType.TEXT_PLAIN).content("x"))
				.andExpect(status().isUnsupportedMediaType())
				.andExpect(jsonPath("$.code").value("UNSUPPORTED_MEDIA_TYPE"));
	}

	@Test
	void missingOrUnsupportedLanguageFallsBackToEnglish() throws Exception {
		String en = messages.getMessage("error.EMAIL_TAKEN", null, Locale.ENGLISH);
		mockMvc.perform(get("/api/v1/test/api-error")).andExpect(jsonPath("$.detail").value(en));
		mockMvc.perform(get("/api/v1/test/api-error").header("Accept-Language", "fr"))
				.andExpect(jsonPath("$.detail").value(en));
	}

}
