package com.anafitlab.backend.support;

import java.time.Instant;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.anafitlab.backend.auth.AccessTokenIssuer;
import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.AppUserRepository;
import com.anafitlab.backend.auth.Role;
import com.anafitlab.backend.auth.TokenHasher;
import com.anafitlab.backend.auth.UserStatus;
import com.anafitlab.backend.client.CoachClient;
import com.anafitlab.backend.client.CoachClientRepository;
import com.anafitlab.backend.client.CoachInvite;
import com.anafitlab.backend.client.CoachInviteRepository;
import com.anafitlab.backend.client.InviteStatus;
import com.anafitlab.backend.client.RelationshipStatus;

/** Repository-level helpers for tests. Inject it; it is registered by TestSupportConfig. */
@Component
public class TestFixtures {

	public static final String PASSWORD = "correct-horse-1";

	private final AppUserRepository users;
	private final CoachClientRepository links;
	private final CoachInviteRepository invites;
	private final PasswordEncoder encoder;
	private final AccessTokenIssuer issuer;

	public TestFixtures(AppUserRepository users, CoachClientRepository links, CoachInviteRepository invites,
			PasswordEncoder encoder, AccessTokenIssuer issuer) {
		this.users = users;
		this.links = links;
		this.invites = invites;
		this.encoder = encoder;
		this.issuer = issuer;
	}

	public AppUser user(Role role, UserStatus status, String email) {
		return user(role, status, email, "Test", role.name());
	}

	public AppUser user(Role role, UserStatus status, String email, String firstName, String lastName) {
		AppUser u = new AppUser();
		u.setEmail(email);
		u.setPasswordHash(encoder.encode(PASSWORD));
		u.setRole(role);
		u.setFirstName(firstName);
		u.setLastName(lastName);
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

	/** An invite with a random code that no test knows; use the API when the code is needed. */
	public CoachInvite invite(AppUser coach, String name, String email, InviteStatus status, Instant expiresAt) {
		CoachInvite i = new CoachInvite();
		i.setCoachId(coach.getId());
		i.setCodeHash(TokenHasher.sha256(UUID.randomUUID().toString()));
		i.setLabel(name);
		i.setEmail(email);
		i.setStatus(status);
		i.setExpiresAt(expiresAt);
		return invites.save(i);
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
