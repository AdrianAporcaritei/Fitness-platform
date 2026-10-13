package com.anafitlab.backend.auth.service;

/** Fields needed to create an account; the password is plain text and is hashed by the registrar. */
public record NewUser(String email, String password, String firstName, String lastName, String locale,
		String timezone) {
}
