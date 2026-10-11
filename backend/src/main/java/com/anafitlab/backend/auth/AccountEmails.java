package com.anafitlab.backend.auth;

import java.util.Locale;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import com.anafitlab.backend.common.AppProperties;
import com.anafitlab.backend.common.mail.OutgoingEmail;

/** Composes localized account emails. Must be called inside a transaction; sending happens after commit. */
@Component
public class AccountEmails {

	private final MessageSource messages;
	private final AppProperties app;
	private final ApplicationEventPublisher events;

	public AccountEmails(MessageSource messages, AppProperties app, ApplicationEventPublisher events) {
		this.messages = messages;
		this.app = app;
		this.events = events;
	}

	public void sendVerification(AppUser user, String rawToken) {
		publish(user, "email.verification", "/verify-email?token=" + rawToken);
	}

	public void sendPasswordReset(AppUser user, String rawToken) {
		publish(user, "email.reset", "/reset-password?token=" + rawToken);
	}

	private void publish(AppUser user, String key, String pathAndQuery) {
		if (!TransactionSynchronizationManager.isActualTransactionActive()) {
			throw new IllegalStateException("Account emails must be sent inside a transaction");
		}
		Locale locale = Locale.forLanguageTag(user.getLocale());
		String link = app.baseUrlWithoutTrailingSlash() + pathAndQuery;
		String subject = messages.getMessage(key + ".subject", null, locale);
		String body = messages.getMessage(key + ".body", new Object[] {link, user.getFirstName()}, locale);
		events.publishEvent(new OutgoingEmail(user.getEmail(), subject, body));
	}

}
