package com.anafitlab.backend.auth;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.auth.dto.LoginRequest;
import com.anafitlab.backend.auth.dto.RegisterCoachRequest;
import com.anafitlab.backend.auth.dto.TokenResponse;
import com.anafitlab.backend.common.security.ClientIp;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
class AuthController {

	private final AuthService auth;

	AuthController(AuthService auth) {
		this.auth = auth;
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

}
