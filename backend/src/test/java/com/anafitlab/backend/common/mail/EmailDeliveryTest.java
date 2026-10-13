package com.anafitlab.backend.common.mail;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.transaction.support.TransactionTemplate;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.auth.service.AccountEmails;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.RecordingEmailSender;
import com.anafitlab.backend.support.TestFixtures;

class EmailDeliveryTest extends IntegrationTestBase {

	@Autowired
	private AccountEmails accountEmails;

	@Autowired
	private TransactionTemplate tx;

	@Autowired
	private RecordingEmailSender sender;

	@Autowired
	private TestFixtures fixtures;

	private AppUser roUser() {
		AppUser user = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "ana@example.com");
		fixtures.setLocale(user, "ro");
		return user;
	}

	@Test
	void sendsAfterCommit() {
		AppUser user = roUser();
		tx.executeWithoutResult(s -> accountEmails.sendVerification(user, "abc_DEF-123"));

		assertThat(sender.sent()).hasSize(1);
		OutgoingEmail email = sender.lastTo("ana@example.com");
		assertThat(email.subject()).isEqualTo("Confirmă adresa de email pentru Ana Fit Lab");
		assertThat(email.body()).contains("http://app.test/verify-email?token=abc_DEF-123");
		assertThat(sender.extractToken(email)).isEqualTo("abc_DEF-123");
		assertThat(email.body()).contains("Salut, Test,");
	}

	@Test
	void sendsResetEmailInEnglishByDefault() {
		AppUser user = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "en@example.com");
		tx.executeWithoutResult(s -> accountEmails.sendPasswordReset(user, "tok"));

		OutgoingEmail email = sender.lastTo("en@example.com");
		assertThat(email.subject()).isEqualTo("Reset your Ana Fit Lab password");
		assertThat(email.body()).contains("http://app.test/reset-password?token=tok");
	}

	@Test
	void doesNotSendOnRollback() {
		AppUser user = roUser();
		tx.executeWithoutResult(s -> {
			accountEmails.sendVerification(user, "tok");
			s.setRollbackOnly();
		});

		assertThat(sender.sent()).isEmpty();
	}

	@Test
	void senderFailureDoesNotPropagate() {
		AppUser user = roUser();
		sender.failOnSend(true);

		assertThatCode(() -> tx.executeWithoutResult(s -> accountEmails.sendVerification(user, "tok")))
			.doesNotThrowAnyException();
		assertThat(sender.sent()).isEmpty();
	}

	@Test
	void failsFastOutsideTransaction() {
		AppUser user = roUser();
		assertThatThrownBy(() -> accountEmails.sendVerification(user, "tok"))
			.isInstanceOf(IllegalStateException.class);
	}

	@Test
	void keepsBootDefaultTaskExecutor(@Autowired ApplicationContext context) {
		assertThat(context.containsBean("applicationTaskExecutor")).isTrue();
	}

}
