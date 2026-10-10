package com.anafitlab.backend.common.security;

import java.io.IOException;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import com.anafitlab.backend.common.error.ProblemDetails;
import com.anafitlab.backend.common.error.RequestLocaleResolver;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import tools.jackson.databind.json.JsonMapper;

/** 403 as a problem+json body for an authenticated caller without the required role. */
@Component
class ProblemAccessDeniedHandler implements AccessDeniedHandler {

	private final ProblemDetails problems;

	private final RequestLocaleResolver localeResolver;

	private final JsonMapper mapper;

	ProblemAccessDeniedHandler(ProblemDetails problems, RequestLocaleResolver localeResolver, JsonMapper mapper) {
		this.problems = problems;
		this.localeResolver = localeResolver;
		this.mapper = mapper;
	}

	@Override
	public void handle(HttpServletRequest request, HttpServletResponse response,
			AccessDeniedException accessDeniedException) throws IOException {
		ProblemDetail problem = problems.of(HttpStatus.FORBIDDEN, "FORBIDDEN", localeResolver.resolve(request));
		response.setStatus(HttpStatus.FORBIDDEN.value());
		response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
		response.setCharacterEncoding("UTF-8");
		mapper.writeValue(response.getWriter(), problem);
	}

}
