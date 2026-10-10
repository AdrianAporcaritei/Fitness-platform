package com.anafitlab.backend.client;

import java.security.SecureRandom;
import java.util.Locale;

public final class InviteCodes {

	private static final String ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";

	private static final int LENGTH = 10;

	private static final SecureRandom RANDOM = new SecureRandom();

	private InviteCodes() {
	}

	public static String generate() {
		StringBuilder sb = new StringBuilder(LENGTH);
		for (int i = 0; i < LENGTH; i++) {
			sb.append(ALPHABET.charAt(RANDOM.nextInt(ALPHABET.length())));
		}
		return sb.toString();
	}

	/** Canonical form: uppercase, no spaces or dashes, O to 0, I and L to 1. */
	public static String normalize(String input) {
		return input.toUpperCase(Locale.ROOT)
			.replaceAll("[\\s-]", "")
			.replace('O', '0')
			.replace('I', '1')
			.replace('L', '1');
	}

	/** {@code XXXXX-XXXXX} form of a normalized code. */
	public static String display(String code) {
		return code.substring(0, 5) + "-" + code.substring(5);
	}

}
