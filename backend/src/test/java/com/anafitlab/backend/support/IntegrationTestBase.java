package com.anafitlab.backend.support;

import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import com.anafitlab.backend.TestcontainersConfiguration;
import com.anafitlab.backend.common.ratelimit.RateLimiter;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import({TestcontainersConfiguration.class, TestSupportConfig.class})
public abstract class IntegrationTestBase {

	@Autowired
	private JdbcTemplate jdbc;

	@Autowired
	private MutableClock clock;

	@Autowired
	private RateLimiter rateLimiter;

	@BeforeEach
	void resetState() {
		clock.set(TestSupportConfig.START);
		rateLimiter.reset();
		jdbc.execute("TRUNCATE app_user, coach_profile, coach_client, coach_invite, refresh_token, user_action_token CASCADE");
	}

}
