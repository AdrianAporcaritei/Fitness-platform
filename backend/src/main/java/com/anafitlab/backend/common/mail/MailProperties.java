package com.anafitlab.backend.common.mail;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties("app.mail")
public record MailProperties(String from, boolean synchronous) {
}
