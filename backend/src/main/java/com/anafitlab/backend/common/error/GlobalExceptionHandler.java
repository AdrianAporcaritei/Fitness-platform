package com.anafitlab.backend.common.error;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.MessageSourceResolvable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.Errors;
import org.springframework.validation.method.ParameterErrors;
import org.springframework.validation.method.ParameterValidationResult;
import org.springframework.web.HttpMediaTypeNotAcceptableException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.method.annotation.HandlerMethodValidationException;
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
		return validationFailed(bindingErrors(ex.getBindingResult()), localeOf(request));
	}

	@Override
	protected ResponseEntity<Object> handleHandlerMethodValidationException(HandlerMethodValidationException ex,
			HttpHeaders headers, HttpStatusCode status, WebRequest request) {
		List<Map<String, String>> errors = new ArrayList<>();
		for (ParameterValidationResult result : ex.getParameterValidationResults()) {
			if (result instanceof ParameterErrors parameterErrors) {
				errors.addAll(bindingErrors(parameterErrors));
			}
			else {
				String field = result.getMethodParameter().getParameterName();
				for (MessageSourceResolvable error : result.getResolvableErrors()) {
					errors.add(error(field == null ? "parameter" : field, error.getDefaultMessage()));
				}
			}
		}
		return validationFailed(errors, localeOf(request));
	}

	/** Every other framework exception: a localized problem with a stable code. */
	@Override
	protected ResponseEntity<Object> handleExceptionInternal(Exception ex, Object body, HttpHeaders headers,
			HttpStatusCode statusCode, WebRequest request) {
		HttpStatus status = HttpStatus.resolve(statusCode.value());
		if (status == null || status.is5xxServerError()) {
			status = HttpStatus.INTERNAL_SERVER_ERROR;
		}
		String code = switch (ex) {
			case HttpRequestMethodNotSupportedException e -> "METHOD_NOT_ALLOWED";
			case HttpMediaTypeNotSupportedException e -> "UNSUPPORTED_MEDIA_TYPE";
			case HttpMediaTypeNotAcceptableException e -> "NOT_ACCEPTABLE";
			default -> status == HttpStatus.NOT_FOUND ? "NOT_FOUND"
					: status.is5xxServerError() ? "INTERNAL_ERROR" : "MALFORMED_REQUEST";
		};
		return respond(problems.of(status, code, localeOf(request)), headers);
	}

	@ExceptionHandler(AccessDeniedException.class)
	ResponseEntity<Object> handleAccessDenied(AccessDeniedException ex, HttpServletRequest request) {
		return respond(problems.of(HttpStatus.FORBIDDEN, "FORBIDDEN", localeResolver.resolve(request)),
				new HttpHeaders());
	}

	@ExceptionHandler(AuthenticationException.class)
	ResponseEntity<Object> handleAuthentication(AuthenticationException ex, HttpServletRequest request) {
		return respond(problems.of(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", localeResolver.resolve(request)),
				new HttpHeaders());
	}

	private ResponseEntity<Object> validationFailed(List<Map<String, String>> errors, Locale locale) {
		ProblemDetail problem = problems.of(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", locale);
		problem.setProperty("errors", errors);
		return respond(problem, new HttpHeaders());
	}

	private List<Map<String, String>> bindingErrors(Errors errors) {
		List<Map<String, String>> result = new ArrayList<>();
		errors.getFieldErrors().forEach(e -> result.add(error(e.getField(), e.getDefaultMessage())));
		errors.getGlobalErrors().forEach(e -> result.add(error(e.getObjectName(), e.getDefaultMessage())));
		return result;
	}

	private static Map<String, String> error(String field, String code) {
		return Map.of("field", field, "code", code == null || code.isBlank() ? "INVALID" : code);
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
