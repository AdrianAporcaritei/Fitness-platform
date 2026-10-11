package com.anafitlab.backend.common.mail;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
public class EmailDeliveryListener {

	private static final Logger log = LoggerFactory.getLogger(EmailDeliveryListener.class);

	private final EmailSender sender;
	private final EmailDispatcher dispatcher;

	public EmailDeliveryListener(EmailSender sender, EmailDispatcher dispatcher) {
		this.sender = sender;
		this.dispatcher = dispatcher;
	}

	@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
	public void onEmail(OutgoingEmail email) {
		try {
			dispatcher.dispatch(() -> deliver(email));
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
