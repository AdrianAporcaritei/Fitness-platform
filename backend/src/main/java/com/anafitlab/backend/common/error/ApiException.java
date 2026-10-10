package com.anafitlab.backend.common.error;

import org.springframework.http.HttpStatus;

/** A business error with a stable machine-readable code; its detail comes from message key {@code error.<code>}. */
public class ApiException extends RuntimeException {

	private final HttpStatus status;

	private final String code;

	private final Object[] args;

	public ApiException(HttpStatus status, String code, Object... args) {
		super(code);
		this.status = status;
		this.code = code;
		this.args = args;
	}

	public HttpStatus status() {
		return status;
	}

	public String code() {
		return code;
	}

	public Object[] args() {
		return args;
	}

}
