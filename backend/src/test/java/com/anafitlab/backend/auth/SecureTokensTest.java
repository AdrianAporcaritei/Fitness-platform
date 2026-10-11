package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.HashSet;
import java.util.Set;

import org.junit.jupiter.api.Test;

class SecureTokensTest {

	@Test
	void generatesDistinct43CharTokens() {
		Set<String> seen = new HashSet<>();
		for (int i = 0; i < 1000; i++) {
			String t = SecureTokens.generate();
			assertThat(t).matches("^[A-Za-z0-9_-]{43}$");
			seen.add(t);
		}
		assertThat(seen).hasSize(1000);
	}

}
