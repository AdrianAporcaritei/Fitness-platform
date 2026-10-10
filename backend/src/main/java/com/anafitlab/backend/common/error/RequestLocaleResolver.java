package com.anafitlab.backend.common.error;

import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.AppUserRepository;

import jakarta.servlet.http.HttpServletRequest;

/**
 * The single place that decides which locale an error message uses: the authenticated user's locale when the
 * request carries a valid access token, otherwise Accept-Language ({@code ro} or {@code en}, default {@code en}).
 */
@Component
public class RequestLocaleResolver {

	private static final List<String> SUPPORTED = List.of("ro", "en");

	private final AppUserRepository users;

	RequestLocaleResolver(AppUserRepository users) {
		this.users = users;
	}

	public Locale resolve(HttpServletRequest request) {
		Locale userLocale = authenticatedUserLocale();
		return userLocale != null ? userLocale : fromAcceptLanguage(request);
	}

	private Locale authenticatedUserLocale() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		if (!(authentication instanceof JwtAuthenticationToken token)) {
			return null;
		}
		try {
			UUID id = UUID.fromString(token.getToken().getSubject());
			return users.findById(id).map(AppUser::getLocale).filter(SUPPORTED::contains)
					.map(Locale::forLanguageTag).orElse(null);
		}
		catch (IllegalArgumentException | NullPointerException e) {
			return null;
		}
	}

	private static Locale fromAcceptLanguage(HttpServletRequest request) {
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
