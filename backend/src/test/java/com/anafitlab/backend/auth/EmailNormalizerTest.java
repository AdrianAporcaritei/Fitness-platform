package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class EmailNormalizerTest {

	@Test
	void trimsAndLowercases() {
		assertThat(EmailNormalizer.normalize(" Ana@Example.RO ")).isEqualTo("ana@example.ro");
	}

}
