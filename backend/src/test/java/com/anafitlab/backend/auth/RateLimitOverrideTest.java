package com.anafitlab.backend.auth;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import com.anafitlab.backend.support.IntegrationTestBase;

@TestPropertySource(properties = "app.rate-limit.signup-ip.max=2")
class RateLimitOverrideTest extends IntegrationTestBase {

	@Autowired
	MockMvc mockMvc;

	private void signup(String email, int expected) throws Exception {
		mockMvc.perform(post("/api/v1/auth/register/coach").contentType(MediaType.APPLICATION_JSON)
				.content("""
						{"email":"%s","password":"correct-horse-1","firstName":"A","lastName":"B",
						"locale":"en","timezone":"Europe/Bucharest"}""".formatted(email)))
				.andExpect(status().is(expected));
	}

	@Test
	void signupIpMaxCanBeOverriddenByProperty() throws Exception {
		signup("a@x.test", 201);
		signup("b@x.test", 201);
		signup("c@x.test", 429);
	}

}
