package com.anafitlab.backend.support;

import java.time.Instant;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.Primary;

@TestConfiguration(proxyBeanMethods = false)
@Import(TestFixtures.class)
public class TestSupportConfig {

	public static final Instant START = Instant.parse("2026-01-15T10:00:00Z");

	@Bean
	@Primary
	MutableClock mutableClock() {
		return new MutableClock(START);
	}

}
