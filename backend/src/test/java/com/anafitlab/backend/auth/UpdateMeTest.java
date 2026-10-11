package com.anafitlab.backend.auth;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.TestFixtures;

class UpdateMeTest extends IntegrationTestBase {

	@Autowired
	MockMvc mockMvc;

	@Autowired
	TestFixtures fixtures;

	private ResultActions update(AppUser user, String body) throws Exception {
		return mockMvc.perform(patch("/api/v1/me").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(user))
				.contentType(MediaType.APPLICATION_JSON).content(body));
	}

	@Test
	void partialUpdate() throws Exception {
		AppUser user = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "u@x.test");
		update(user, "{\"locale\":\"ro\"}").andExpect(status().isOk())
			.andExpect(jsonPath("$.locale").value("ro"))
			.andExpect(jsonPath("$.firstName").value("Test"))
			.andExpect(jsonPath("$.lastName").value("CLIENT"))
			.andExpect(jsonPath("$.timezone").value("Europe/Bucharest"));
		// the stored locale now drives the error detail language
		update(user, "{\"timezone\":\"Mars/Base\"}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("INVALID_TIMEZONE"))
			.andExpect(jsonPath("$.detail").value("Cererea conține date invalide."));
		mockMvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(user)))
			.andExpect(jsonPath("$.locale").value("ro"));
	}

	@Test
	void updatesNamesAndTimezone() throws Exception {
		AppUser user = fixtures.user(Role.COACH, UserStatus.ACTIVE, "u@x.test");
		update(user, "{\"firstName\":\"Ana\",\"lastName\":\"Pop\",\"timezone\":\"Europe/London\"}")
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.firstName").value("Ana"))
			.andExpect(jsonPath("$.lastName").value("Pop"))
			.andExpect(jsonPath("$.timezone").value("Europe/London"))
			.andExpect(jsonPath("$.locale").value("en"));
	}

	@Test
	void emptyBodyChangesNothing() throws Exception {
		AppUser user = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "u@x.test");
		update(user, "{}").andExpect(status().isOk())
			.andExpect(jsonPath("$.firstName").value("Test"))
			.andExpect(jsonPath("$.locale").value("en"));
	}

	@Test
	void explicitNullLeavesFieldUnchanged() throws Exception {
		AppUser user = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "u@x.test");
		update(user, "{\"firstName\":null,\"locale\":null}").andExpect(status().isOk())
			.andExpect(jsonPath("$.firstName").value("Test"))
			.andExpect(jsonPath("$.locale").value("en"));
	}

	@Test
	void invalidValues() throws Exception {
		AppUser user = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "u@x.test");
		update(user, "{\"firstName\":\"  \"}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("REQUIRED"));
		update(user, "{\"lastName\":\"" + "x".repeat(101) + "\"}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("TOO_LONG"));
		update(user, "{\"locale\":\"fr\"}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("INVALID_LOCALE"));
	}

	@Test
	void requiresAuthentication() throws Exception {
		mockMvc.perform(patch("/api/v1/me").contentType(MediaType.APPLICATION_JSON).content("{}"))
			.andExpect(status().isUnauthorized());
	}

}
