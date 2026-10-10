package com.anafitlab.backend.auth;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.dto.UserResponse;
import com.anafitlab.backend.common.security.CurrentUser;

@Service
public class AccountService {

	private final CurrentUserAccounts accounts;

	AccountService(CurrentUserAccounts accounts) {
		this.accounts = accounts;
	}

	@Transactional(readOnly = true)
	public UserResponse me(CurrentUser current) {
		return UserResponse.from(accounts.require(current));
	}

}
