package com.anafitlab.backend.common.mail;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.task.TaskExecutor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
public class EmailDeliveryListener {

	private static final Logger log = LoggerFactory.getLogger(EmailDeliveryListener.class);

	private final EmailSender sender;
	private final TaskExecutor executor;

	public EmailDeliveryListener(EmailSender sender, @Qualifier(MailConfig.EMAIL_EXECUTOR) TaskExecutor executor) {
		this.sender = sender;
		this.executor = executor;
	}

	@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
	public void onEmail(OutgoingEmail email) {
		try {
			executor.execute(() -> deliver(email));
		}
		catch (RuntimeException e) {
			log.warn("Could not queue email to {}", email.to(), e);
		}
	}

	private void deliver(OutgoingEmail email) {
		try {
			sender.send(email);
		}
		catch (RuntimeException e) {
			log.warn("Failed to send email to {}", email.to(), e);
		}
	}

}
