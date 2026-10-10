package com.anafitlab.backend.common.mail;

public record OutgoingEmail(String to, String subject, String body) {
}
