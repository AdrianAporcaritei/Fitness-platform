package com.anafitlab.backend.common;

import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties("app")
public record AppProperties(String baseUrl, List<String> corsAllowedOrigins) {
}
