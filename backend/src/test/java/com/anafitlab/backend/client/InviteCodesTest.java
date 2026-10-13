package com.anafitlab.backend.client;

import static org.assertj.core.api.Assertions.assertThat;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;

import com.anafitlab.backend.client.util.InviteCodes;

class InviteCodesTest {

	@Test
	void generatesCrockfordCodes() {
		for (int i = 0; i < 500; i++) {
			assertThat(InviteCodes.generate()).matches("^[0-9ABCDEFGHJKMNPQRSTVWXYZ]{10}$");
		}
	}

	@Test
	void normalizeMapsLookalikesAndStripsSeparators() {
		assertThat(InviteCodes.normalize("k7q2m-9xdoi")).isEqualTo(InviteCodes.normalize("K7Q2M9XD01"));
		assertThat(InviteCodes.normalize(" k7q2-m9xd-l0 ")).isEqualTo("K7Q2M9XD10");
	}

	@Test
	void normalizeNullAndEmptyGiveEmpty() {
		assertThat(InviteCodes.normalize(null)).isEmpty();
		assertThat(InviteCodes.normalize("")).isEmpty();
	}

	@Test
	void displayRejectsBadLength() {
		assertThatThrownBy(() -> InviteCodes.display("ABC")).isInstanceOf(IllegalArgumentException.class);
		assertThatThrownBy(() -> InviteCodes.display(null)).isInstanceOf(IllegalArgumentException.class);
		assertThatThrownBy(() -> InviteCodes.display("K7Q2M9XD101")).isInstanceOf(IllegalArgumentException.class);
	}

	@Test
	void displaysInTwoGroups() {
		assertThat(InviteCodes.display("K7Q2M9XD10")).isEqualTo("K7Q2M-9XD10");
	}

}
