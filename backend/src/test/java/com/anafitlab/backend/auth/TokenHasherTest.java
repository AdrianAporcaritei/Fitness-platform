package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

import com.anafitlab.backend.auth.util.TokenHasher;

class TokenHasherTest {

	@Test
	void knownVector() {
		assertThat(TokenHasher.sha256("abc"))
			.isEqualTo("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
	}

}
