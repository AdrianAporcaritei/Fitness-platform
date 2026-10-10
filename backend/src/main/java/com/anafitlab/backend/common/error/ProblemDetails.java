package com.anafitlab.backend.common.error;

import java.util.Locale;

import org.springframework.context.MessageSource;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.stereotype.Component;

/** Builds RFC 9457 problem bodies with a stable {@code code} and a localized {@code detail}. */
@Component
public class ProblemDetails {

	private final MessageSource messages;

	public ProblemDetails(MessageSource messages) {
		this.messages = messages;
	}

	public ProblemDetail of(HttpStatus status, String code, Locale locale, Object... args) {
		String detail = messages.getMessage("error." + code, args, code, locale);
		ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, detail);
		problem.setProperty("code", code);
		return problem;
	}

}
