package com.anafitlab.backend.auth.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.repository.AppUserRepository;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.security.CurrentUser;

/** Loads the caller's account. A valid token can outlive its user, which is a 401, never a 500. */
@Component
public class CurrentUserAccounts {

	private final AppUserRepository users;

	CurrentUserAccounts(AppUserRepository users) {
		this.users = users;
	}

	public AppUser require(CurrentUser current) {
		return users.findById(current.id()).orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED"));
	}

}
