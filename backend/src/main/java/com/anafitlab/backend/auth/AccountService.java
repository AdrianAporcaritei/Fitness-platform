package com.anafitlab.backend.auth;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.dto.UserResponse;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.security.CurrentUser;

@Service
public class AccountService {

	private final AppUserRepository users;

	AccountService(AppUserRepository users) {
		this.users = users;
	}

	/** A token can outlive its user (account deleted); that is a 401, not a 500. */
	@Transactional(readOnly = true)
	public UserResponse me(CurrentUser current) {
		return users.findById(current.id()).map(UserResponse::from)
				.orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED"));
	}

}
