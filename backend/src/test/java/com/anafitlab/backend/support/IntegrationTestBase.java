package com.anafitlab.backend.support;

import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import com.anafitlab.backend.TestcontainersConfiguration;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import({TestcontainersConfiguration.class, TestSupportConfig.class})
public abstract class IntegrationTestBase {

	@Autowired
	private JdbcTemplate jdbc;

	@BeforeEach
	void resetDatabase() {
		jdbc.execute("TRUNCATE app_user, coach_profile, coach_client, coach_invite, refresh_token, user_action_token CASCADE");
	}

}
