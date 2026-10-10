package com.anafitlab.backend.auth;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.auth.dto.UserResponse;
import com.anafitlab.backend.common.security.CurrentUser;

@RestController
class MeController {

	private final AccountService accounts;

	MeController(AccountService accounts) {
		this.accounts = accounts;
	}

	@GetMapping("/me")
	UserResponse me(CurrentUser current) {
		return accounts.me(current);
	}

}
