package com.anafitlab.backend.client;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.Role;
import com.anafitlab.backend.auth.UserStatus;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.TestFixtures;

class CoachProfileTest extends IntegrationTestBase {

	@Autowired
	MockMvc mockMvc;

	@Autowired
	TestFixtures fixtures;

	private ResultActions update(AppUser coach, String body) throws Exception {
		return mockMvc.perform(patch("/api/v1/coach/profile").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach))
				.contentType(MediaType.APPLICATION_JSON).content(body));
	}

	private ResultActions read(AppUser coach) throws Exception {
		return mockMvc.perform(get("/api/v1/coach/profile").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach)));
	}

	@Test
	void missingProfileRowReadsAsEmpty() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "c@x.test");
		read(coach).andExpect(status().isOk())
			.andExpect(jsonPath("$.bio").doesNotExist())
			.andExpect(jsonPath("$.specializations.length()").value(0));
	}

	@Test
	void getAndUpdate() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "c@x.test");
		update(coach, "{\"bio\":\"Hello\",\"specializations\":[\"strength\",\"mobility\"]}")
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.bio").value("Hello"));
		read(coach).andExpect(jsonPath("$.bio").value("Hello"))
			.andExpect(jsonPath("$.specializations[1]").value("mobility"));
		// partial: only bio changes
		update(coach, "{\"bio\":\"New\"}").andExpect(status().isOk());
		read(coach).andExpect(jsonPath("$.bio").value("New"))
			.andExpect(jsonPath("$.specializations.length()").value(2));
	}

	@Test
	void validationCodes() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "c@x.test");
		String many = IntStream.range(0, 21).mapToObj(i -> "\"s" + i + "\"").collect(Collectors.joining(","));
		update(coach, "{\"specializations\":[" + many + "]}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("TOO_MANY"));
		update(coach, "{\"bio\":\"" + "x".repeat(2001) + "\"}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("TOO_LONG"));
		update(coach, "{\"specializations\":[\" \"]}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("REQUIRED"));
		update(coach, "{\"specializations\":[\"" + "x".repeat(51) + "\"]}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("TOO_LONG"));
	}

	@Test
	void clientIsForbidden() throws Exception {
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "cl@x.test");
		read(client).andExpect(status().isForbidden());
		update(client, "{}").andExpect(status().isForbidden());
	}

}
