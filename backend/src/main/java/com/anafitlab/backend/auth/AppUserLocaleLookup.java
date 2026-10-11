package com.anafitlab.backend.auth;

import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Component;

import com.anafitlab.backend.common.error.UserLocaleLookup;

@Component
class AppUserLocaleLookup implements UserLocaleLookup {

	private final AppUserRepository users;

	AppUserLocaleLookup(AppUserRepository users) {
		this.users = users;
	}

	@Override
	public Optional<String> localeOf(UUID userId) {
		return users.findById(userId).map(AppUser::getLocale);
	}

}
