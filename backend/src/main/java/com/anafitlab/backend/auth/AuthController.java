package com.anafitlab.backend.auth;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.auth.dto.LoginRequest;
import com.anafitlab.backend.auth.dto.LogoutRequest;
import com.anafitlab.backend.auth.dto.RefreshRequest;
import com.anafitlab.backend.auth.dto.RegisterCoachRequest;
import com.anafitlab.backend.auth.dto.TokenResponse;
import com.anafitlab.backend.auth.dto.VerifyEmailRequest;
import com.anafitlab.backend.common.security.ClientIp;
import com.anafitlab.backend.common.security.CurrentUser;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
class AuthController {

	private final AuthService auth;
	private final AccountService accounts;

	AuthController(AuthService auth, AccountService accounts) {
		this.auth = auth;
		this.accounts = accounts;
	}

	@PostMapping("/auth/register/coach")
	@ResponseStatus(HttpStatus.CREATED)
	TokenResponse registerCoach(@Valid @RequestBody RegisterCoachRequest request, HttpServletRequest http) {
		return auth.registerCoach(request, ClientIp.of(http));
	}

	@PostMapping("/auth/login")
	TokenResponse login(@Valid @RequestBody LoginRequest request, HttpServletRequest http) {
		return auth.login(request, ClientIp.of(http));
	}

	@PostMapping("/auth/refresh")
	TokenResponse refresh(@Valid @RequestBody RefreshRequest request) {
		return auth.refresh(request);
	}

	@PostMapping("/auth/logout")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	void logout(@Valid @RequestBody LogoutRequest request) {
		auth.logout(request);
	}

	@PostMapping("/auth/logout-all")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	void logoutAll(CurrentUser current) {
		auth.logoutAll(current);
	}

	@PostMapping("/auth/verify-email")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	void verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
		accounts.verifyEmail(request.token());
	}

	@PostMapping("/auth/verify-email/resend")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	void resendVerification(CurrentUser current) {
		accounts.resendVerification(current);
	}

}
