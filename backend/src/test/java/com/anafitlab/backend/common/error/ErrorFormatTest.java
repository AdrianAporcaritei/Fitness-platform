package com.anafitlab.backend.common.error;

import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Locale;

import com.anafitlab.backend.TestcontainersConfiguration;

@Import(TestcontainersConfiguration.class)
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@WithMockUser
class ErrorFormatTest {

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
		mockMvc.perform(get("/api/v1/test/api-error").header("Accept-Language", "ro"))
				.andExpect(jsonPath("$.detail").value(ro));
		mockMvc.perform(get("/api/v1/test/api-error").header("Accept-Language", "en"))
				.andExpect(jsonPath("$.detail").value(en));
		assertNotEquals(ro, en);
	}

	@Test
	void validationErrorsListFieldCodes() throws Exception {
		mockMvc.perform(post("/api/v1/test/validate").with(csrf()).contentType(MediaType.APPLICATION_JSON).content("{}"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
				.andExpect(jsonPath("$.errors[0].field").value("name"))
				.andExpect(jsonPath("$.errors[0].code").value("REQUIRED"));
	}

	@Test
	void malformedJsonIs400() throws Exception {
		mockMvc.perform(post("/api/v1/test/validate").with(csrf()).contentType(MediaType.APPLICATION_JSON).content("{"))
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
		mockMvc.perform(post("/api/v1/test/api-error").with(csrf())).andExpect(status().isMethodNotAllowed())
				.andExpect(jsonPath("$.code").value("METHOD_NOT_ALLOWED"))
				.andExpect(header().exists("Allow"));
	}

	@Test
	void wrongContentTypeIs415WithCode() throws Exception {
		mockMvc.perform(post("/api/v1/test/validate").with(csrf()).contentType(MediaType.TEXT_PLAIN).content("x"))
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
