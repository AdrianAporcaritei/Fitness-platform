package com.anafitlab.backend.common;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.TestcontainersConfiguration;

@Import({ TestcontainersConfiguration.class, ApiPathConfigTest.PingController.class })
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@ActiveProfiles("test")
class ApiPathConfigTest {

	@Autowired
	MockMvc mockMvc;

	@Test
	void restControllersAreServedUnderApiV1() throws Exception {
		mockMvc.perform(get("/api/v1/ping")).andExpect(status().isOk()).andExpect(content().string("pong"));
		mockMvc.perform(get("/ping")).andExpect(status().isNotFound());
	}

	@TestConfiguration(proxyBeanMethods = false)
	@RestController
	static class PingController {

		@GetMapping("/ping")
		String ping() {
			return "pong";
		}

	}

}
