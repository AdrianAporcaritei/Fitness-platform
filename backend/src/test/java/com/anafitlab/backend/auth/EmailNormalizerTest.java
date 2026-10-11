package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class EmailNormalizerTest {

	@Test
	void nullStaysNull() {
		assertThat(EmailNormalizer.normalize(null)).isNull();
	}

	@Test
	void trimsAndLowercases() {
		assertThat(EmailNormalizer.normalize(" Ana@Example.RO ")).isEqualTo("ana@example.ro");
	}

}
