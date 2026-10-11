package com.anafitlab.backend.support;

import java.time.Instant;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.anafitlab.backend.auth.AccessTokenIssuer;
import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.AppUserRepository;
import com.anafitlab.backend.auth.Role;
import com.anafitlab.backend.auth.UserStatus;
import com.anafitlab.backend.client.CoachClient;
import com.anafitlab.backend.client.CoachClientRepository;
import com.anafitlab.backend.client.RelationshipStatus;

/** Repository-level helpers for tests. Inject it; it is registered by TestSupportConfig. */
@Component
public class TestFixtures {

	public static final String PASSWORD = "correct-horse-1";

	private final AppUserRepository users;
	private final CoachClientRepository links;
	private final PasswordEncoder encoder;
	private final AccessTokenIssuer issuer;

	public TestFixtures(AppUserRepository users, CoachClientRepository links, PasswordEncoder encoder,
			AccessTokenIssuer issuer) {
		this.users = users;
		this.links = links;
		this.encoder = encoder;
		this.issuer = issuer;
	}

	public AppUser user(Role role, UserStatus status, String email) {
		AppUser u = new AppUser();
		u.setEmail(email);
		u.setPasswordHash(encoder.encode(PASSWORD));
		u.setRole(role);
		u.setFirstName("Test");
		u.setLastName(role.name());
		u.setLocale("en");
		u.setTimezone("Europe/Bucharest");
		u.setStatus(status);
		if (status != UserStatus.PENDING) {
			u.setEmailVerifiedAt(Instant.now());
		}
		return users.save(u);
	}

	public CoachClient link(AppUser coach, AppUser client, RelationshipStatus status) {
		CoachClient l = new CoachClient();
		l.setCoachId(coach.getId());
		l.setClientId(client.getId());
		l.setStatus(status);
		l.setStartedAt(Instant.now());
		return links.save(l);
	}

	/** Authorization header value carrying a fresh access token for the user. */
	public String bearer(AppUser user) {
		return "Bearer " + issuer.issue(user).token();
	}

	public void setLocale(AppUser user, String locale) {
		user.setLocale(locale);
		users.save(user);
	}

	public void delete(AppUser user) {
		users.deleteById(user.getId());
	}

}
