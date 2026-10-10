package com.anafitlab.backend.common.error;

import java.time.Duration;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;

/** Test-only endpoints that raise each error kind. */
@RestController
class ErrorTestController {

	record NameRequest(@NotBlank(message = "REQUIRED") String name) {
	}

	@GetMapping("/test/api-error")
	void apiError() {
		throw new ApiException(HttpStatus.CONFLICT, "EMAIL_TAKEN");
	}

	@PostMapping("/test/validate")
	void validate(@Valid @RequestBody NameRequest request) {
	}

	@GetMapping("/test/rate-limited")
	void rateLimited() {
		throw new RateLimitedException(Duration.ofSeconds(90));
	}

	@GetMapping("/test/boom")
	void boom() {
		throw new IllegalStateException("secret internal detail");
	}

}
