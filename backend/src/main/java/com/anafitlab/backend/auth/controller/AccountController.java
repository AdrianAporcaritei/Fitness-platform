package com.anafitlab.backend.auth.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.auth.dto.ChangePasswordRequest;
import com.anafitlab.backend.auth.dto.UpdateMeRequest;
import com.anafitlab.backend.auth.dto.UserResponse;
import com.anafitlab.backend.auth.service.AccountService;
import com.anafitlab.backend.common.security.CurrentUser;

import jakarta.validation.Valid;

@RestController
class AccountController {

	private final AccountService accounts;

	AccountController(AccountService accounts) {
		this.accounts = accounts;
	}

	@GetMapping("/me")
	UserResponse me(CurrentUser current) {
		return accounts.me(current);
	}

	@PatchMapping("/me")
	UserResponse update(CurrentUser current, @Valid @RequestBody UpdateMeRequest request) {
		return accounts.updateMe(current, request);
	}

	@PostMapping("/me/password")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	void changePassword(CurrentUser current, @Valid @RequestBody ChangePasswordRequest request) {
		accounts.changePassword(current, request);
	}

}
