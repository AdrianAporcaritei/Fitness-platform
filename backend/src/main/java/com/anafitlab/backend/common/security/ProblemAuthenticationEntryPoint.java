package com.anafitlab.backend.common.security;

import java.io.IOException;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import com.anafitlab.backend.common.error.ProblemDetails;
import com.anafitlab.backend.common.error.RequestLocaleResolver;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import tools.jackson.databind.json.JsonMapper;

/** 401 as a problem+json body for missing or invalid credentials. */
@Component
class ProblemAuthenticationEntryPoint implements AuthenticationEntryPoint {

	private final ProblemDetails problems;

	private final RequestLocaleResolver localeResolver;

	private final JsonMapper mapper;

	ProblemAuthenticationEntryPoint(ProblemDetails problems, RequestLocaleResolver localeResolver, JsonMapper mapper) {
		this.problems = problems;
		this.localeResolver = localeResolver;
		this.mapper = mapper;
	}

	@Override
	public void commence(HttpServletRequest request, HttpServletResponse response,
			AuthenticationException authException) throws IOException {
		ProblemDetail problem = problems.of(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", localeResolver.resolve(request));
		response.setStatus(HttpStatus.UNAUTHORIZED.value());
		response.setHeader(HttpHeaders.WWW_AUTHENTICATE, "Bearer");
		response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
		response.setCharacterEncoding("UTF-8");
		mapper.writeValue(response.getWriter(), problem);
	}

}
