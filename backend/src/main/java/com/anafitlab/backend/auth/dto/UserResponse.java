package com.anafitlab.backend.auth.dto;

import java.util.UUID;

import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.Role;
import com.anafitlab.backend.auth.UserStatus;

public record UserResponse(UUID id, String email, Role role, UserStatus status, String firstName, String lastName,
		String locale, String timezone) {

	public static UserResponse from(AppUser user) {
		return new UserResponse(user.getId(), user.getEmail(), user.getRole(), user.getStatus(), user.getFirstName(),
				user.getLastName(), user.getLocale(), user.getTimezone());
	}

}
