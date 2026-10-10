package com.anafitlab.backend.security;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;

import org.junit.jupiter.api.Test;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;

import com.anafitlab.backend.common.security.JwtConfig;
import com.anafitlab.backend.common.security.JwtProperties;

class JwtSecretValidationTest {

	private final ApplicationContextRunner runner = new ApplicationContextRunner()
			.withUserConfiguration(TestConfig.class);

	@Test
	void shortSecretFailsStartup() {
		runner.withPropertyValues("app.jwt.secret=too-short").run(context -> {
			assertThat(context).hasFailed();
			assertThat(context.getStartupFailure()).hasRootCauseInstanceOf(IllegalStateException.class)
					.rootCause().hasMessageContaining("app.jwt.secret");
		});
	}

	@Test
	void missingSecretFailsStartup() {
		runner.run(context -> assertThat(context).hasFailed());
	}

	@Test
	void secretIsMeasuredInUtf8Bytes() {
		// 16 two-byte characters = 32 bytes: accepted; 15 of them = 30 bytes: rejected
		runner.withPropertyValues("app.jwt.secret=" + "é".repeat(16)).run(context -> assertThat(context).hasNotFailed());
		runner.withPropertyValues("app.jwt.secret=" + "é".repeat(15)).run(context -> assertThat(context).hasFailed());
	}

	@Test
	void thirtyTwoByteSecretStarts() {
		runner.withPropertyValues("app.jwt.secret=" + "a".repeat(32)).run(context -> assertThat(context).hasNotFailed());
	}

	@org.springframework.context.annotation.Configuration(proxyBeanMethods = false)
	@EnableConfigurationProperties(JwtProperties.class)
	@Import(JwtConfig.class)
	static class TestConfig {

		@Bean
		Clock clock() {
			return Clock.systemUTC();
		}

	}

}
