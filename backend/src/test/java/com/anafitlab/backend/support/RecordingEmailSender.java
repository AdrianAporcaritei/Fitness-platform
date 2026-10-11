package com.anafitlab.backend.support;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.anafitlab.backend.common.mail.EmailSender;
import com.anafitlab.backend.common.mail.OutgoingEmail;

public class RecordingEmailSender implements EmailSender {

	private static final Pattern TOKEN = Pattern.compile("token=([A-Za-z0-9_-]+)");

	private final List<OutgoingEmail> sent = new CopyOnWriteArrayList<>();
	private volatile boolean failing;

	@Override
	public void send(OutgoingEmail email) {
		if (failing) {
			throw new IllegalStateException("simulated send failure");
		}
		sent.add(email);
	}

	public List<OutgoingEmail> sent() {
		return List.copyOf(sent);
	}

	public OutgoingEmail lastTo(String email) {
		return sent.stream().filter(e -> e.to().equals(email)).reduce((a, b) -> b).orElse(null);
	}

	public String extractToken(OutgoingEmail email) {
		Matcher m = TOKEN.matcher(email.body());
		if (!m.find()) {
			throw new IllegalArgumentException("no token in email body");
		}
		return m.group(1);
	}

	public void failOnSend(boolean failing) {
		this.failing = failing;
	}

	public void clear() {
		sent.clear();
		failing = false;
	}

}
