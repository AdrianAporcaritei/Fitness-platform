package com.anafitlab.backend.common.validation;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;

class ValidatorsTest {

	private static final ValidatorFactory FACTORY = Validation.buildDefaultValidatorFactory();

	private static final Validator VALIDATOR = FACTORY.getValidator();

	@AfterAll
	static void close() {
		FACTORY.close();
	}

	record Pw(@ValidPassword String v) {
	}

	record Loc(@ValidLocale String v) {
	}

	record Tz(@ValidTimezone String v) {
	}

	private boolean valid(Object o) {
		return VALIDATOR.validate(o).isEmpty();
	}

	@Test
	void passwordRules() {
		assertThat(valid(new Pw("123456789"))).isFalse();
		assertThat(valid(new Pw("1234567890"))).isTrue();
		assertThat(valid(new Pw("a".repeat(64)))).isTrue();
		assertThat(valid(new Pw("a".repeat(65)))).isFalse();
		// 19 code points (length() == 38) but 76 UTF-8 bytes
		assertThat(valid(new Pw("😀".repeat(19)))).isFalse();
		// 18 emoji = 72 bytes, 18 code points: allowed
		assertThat(valid(new Pw("😀".repeat(18)))).isTrue();
		assertThat(valid(new Pw(null))).isTrue();
	}

	@Test
	void passwordViolationCarriesCode() {
		assertThat(VALIDATOR.validate(new Pw("short")))
			.singleElement()
			.extracting(v -> v.getMessage())
			.isEqualTo("PASSWORD_POLICY");
	}

	@Test
	void localeRules() {
		assertThat(valid(new Loc("ro"))).isTrue();
		assertThat(valid(new Loc("en"))).isTrue();
		assertThat(valid(new Loc("fr"))).isFalse();
		assertThat(valid(new Loc("RO"))).isFalse();
		assertThat(valid(new Loc(""))).isFalse();
		assertThat(VALIDATOR.validate(new Loc("fr")).iterator().next().getMessage()).isEqualTo("INVALID_LOCALE");
	}

	@Test
	void timezoneRules() {
		assertThat(valid(new Tz("Europe/Bucharest"))).isTrue();
		assertThat(valid(new Tz("Mars/Olympus"))).isFalse();
		assertThat(valid(new Tz("+02:00"))).isFalse();
		assertThat(VALIDATOR.validate(new Tz("+02:00")).iterator().next().getMessage()).isEqualTo("INVALID_TIMEZONE");
	}

}
