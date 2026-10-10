package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.context.support.StaticMessageSource;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import com.anafitlab.backend.common.AppProperties;
import com.anafitlab.backend.common.mail.OutgoingEmail;

class AccountEmailsLinkTest {

	@Test
	void trailingSlashInBaseUrlIsStripped() {
		StaticMessageSource messages = new StaticMessageSource();
		messages.setUseCodeAsDefaultMessage(false);
		messages.addMessage("email.verification.subject", java.util.Locale.ENGLISH, "s");
		messages.addMessage("email.verification.body", java.util.Locale.ENGLISH, "{0}|{1}");
		List<Object> events = new ArrayList<>();
		AccountEmails emails = new AccountEmails(messages, new AppProperties("http://app.test/", List.of()),
				events::add);
		AppUser user = new AppUser();
		user.setEmail("a@b.c");
		user.setFirstName("A");
		user.setLocale("en");

		TransactionSynchronizationManager.setActualTransactionActive(true);
		try {
			emails.sendVerification(user, "tok");
		}
		finally {
			TransactionSynchronizationManager.setActualTransactionActive(false);
		}

		assertThat(((OutgoingEmail) events.get(0)).body()).isEqualTo("http://app.test/verify-email?token=tok|A");
	}

}
