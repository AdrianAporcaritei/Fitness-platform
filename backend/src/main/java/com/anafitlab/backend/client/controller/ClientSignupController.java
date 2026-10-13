package com.anafitlab.backend.client.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.auth.dto.TokenResponse;
import com.anafitlab.backend.client.dto.RegisterClientRequest;
import com.anafitlab.backend.client.service.ClientRegistrationService;
import com.anafitlab.backend.common.security.ClientIp;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
class ClientSignupController {

	private final ClientRegistrationService registration;

	ClientSignupController(ClientRegistrationService registration) {
		this.registration = registration;
	}

	@PostMapping("/auth/register/client")
	@ResponseStatus(HttpStatus.CREATED)
	TokenResponse register(@Valid @RequestBody RegisterClientRequest request, HttpServletRequest http) {
		return registration.register(request, ClientIp.of(http));
	}

}
