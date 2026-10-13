package com.anafitlab.backend.auth.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/** Blank values mean "not configured". */
@ConfigurationProperties("app.admin")
public record AdminProperties(String email, String password) {
}
