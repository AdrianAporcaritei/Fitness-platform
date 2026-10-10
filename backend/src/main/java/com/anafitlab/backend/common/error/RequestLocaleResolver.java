package com.anafitlab.backend.common.error;

import java.util.Collections;
import java.util.List;
import java.util.Locale;

import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletRequest;

/**
 * The single place that decides which locale an error message uses: Accept-Language ({@code ro} or {@code en},
 * default {@code en}). The authenticated user's locale is meant to take precedence here once security exists.
 */
@Component
public class RequestLocaleResolver {

	private static final List<String> SUPPORTED = List.of("ro", "en");

	public Locale resolve(HttpServletRequest request) {
		if (request.getHeader("Accept-Language") == null) {
			return Locale.ENGLISH;
		}
		for (Locale candidate : Collections.list(request.getLocales())) {
			if (SUPPORTED.contains(candidate.getLanguage())) {
				return Locale.forLanguageTag(candidate.getLanguage());
			}
		}
		return Locale.ENGLISH;
	}

}
