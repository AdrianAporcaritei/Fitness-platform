package com.anafitlab.backend.common;

import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties("app")
public record AppProperties(String baseUrl, List<String> corsAllowedOrigins) {

	/** The base URL without a trailing slash, ready to be followed by a path. */
	public String baseUrlWithoutTrailingSlash() {
		return baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
	}

}
