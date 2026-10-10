package com.anafitlab.backend.common.error;

import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.ServletWebRequest;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import jakarta.servlet.http.HttpServletRequest;

@RestControllerAdvice
class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

	private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

	private final ProblemDetails problems;

	private final RequestLocaleResolver localeResolver;

	GlobalExceptionHandler(ProblemDetails problems, RequestLocaleResolver localeResolver) {
		this.problems = problems;
		this.localeResolver = localeResolver;
	}

	@ExceptionHandler(ApiException.class)
	ResponseEntity<Object> handleApiException(ApiException ex, HttpServletRequest request) {
		ProblemDetail problem = problems.of(ex.status(), ex.code(), localeResolver.resolve(request), ex.args());
		HttpHeaders headers = new HttpHeaders();
		if (ex instanceof RateLimitedException limited) {
			long seconds = (limited.retryAfter().toMillis() + 999) / 1000;
			headers.set(HttpHeaders.RETRY_AFTER, Long.toString(seconds));
		}
		return respond(problem, headers);
	}

	@ExceptionHandler(Exception.class)
	ResponseEntity<Object> handleUnexpected(Exception ex, HttpServletRequest request) {
		log.error("Unhandled exception on {} {}", request.getMethod(), request.getRequestURI(), ex);
		return respond(problems.of(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR", localeResolver.resolve(request)),
				new HttpHeaders());
	}

	@Override
	protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex,
			HttpHeaders headers, HttpStatusCode status, WebRequest request) {
		ProblemDetail problem = problems.of(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", localeOf(request));
		List<Map<String, String>> errors = ex.getBindingResult().getFieldErrors().stream()
				.map(e -> Map.of("field", e.getField(), "code", String.valueOf(e.getDefaultMessage())))
				.toList();
		problem.setProperty("errors", errors);
		return respond(problem, new HttpHeaders());
	}

	@Override
	protected ResponseEntity<Object> handleHttpMessageNotReadable(HttpMessageNotReadableException ex,
			HttpHeaders headers, HttpStatusCode status, WebRequest request) {
		return respond(problems.of(HttpStatus.BAD_REQUEST, "MALFORMED_REQUEST", localeOf(request)), new HttpHeaders());
	}

	@Override
	protected ResponseEntity<Object> handleNoResourceFoundException(NoResourceFoundException ex, HttpHeaders headers,
			HttpStatusCode status, WebRequest request) {
		return respond(problems.of(HttpStatus.NOT_FOUND, "NOT_FOUND", localeOf(request)), new HttpHeaders());
	}

	private Locale localeOf(WebRequest request) {
		return localeResolver.resolve(((ServletWebRequest) request).getRequest());
	}

	private ResponseEntity<Object> respond(ProblemDetail problem, HttpHeaders headers) {
		return ResponseEntity.status(problem.getStatus()).headers(headers)
				.contentType(MediaType.APPLICATION_PROBLEM_JSON).body(problem);
	}

}
