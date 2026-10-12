package com.anafitlab.backend.client;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.AppUserRepository;
import com.anafitlab.backend.auth.CurrentUserAccounts;
import com.anafitlab.backend.auth.TokenHasher;
import com.anafitlab.backend.auth.UserStatus;
import com.anafitlab.backend.client.dto.InvitationLinkResponse;
import com.anafitlab.backend.client.dto.InvitePreviewResponse;
import com.anafitlab.backend.common.AppProperties;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.ratelimit.RateLimitProperties;
import com.anafitlab.backend.common.ratelimit.RateLimiter;
import com.anafitlab.backend.common.security.CurrentUser;

@Service
public class InviteService {

	static final Duration VALIDITY = Duration.ofDays(7);

	private static final int MAX_GENERATION_ATTEMPTS = 3;

	private final CoachInviteRepository invites;
	private final CoachClientRepository links;
	private final AppUserRepository users;
	private final CurrentUserAccounts accounts;
	private final RateLimiter rateLimiter;
	private final RateLimitProperties limits;
	private final Clock clock;
	private final AppProperties app;

	InviteService(CoachInviteRepository invites, CoachClientRepository links, AppUserRepository users, CurrentUserAccounts accounts,
			RateLimiter rateLimiter, RateLimitProperties limits, Clock clock, AppProperties app) {
		this.invites = invites;
		this.links = links;
		this.users = users;
		this.accounts = accounts;
		this.rateLimiter = rateLimiter;
		this.limits = limits;
		this.clock = clock;
		this.app = app;
	}

	/**
	 * Adds a client by creating a pending invite for them. Duplicates are checked only within the coach's own
	 * data, so the response never reveals other coaches' clients or invites.
	 */
	@Transactional
	public InvitationLinkResponse create(CurrentUser coach, String name, String email) {
		AppUser account = requireVerifiedCoach(coach);
		Instant now = clock.instant();
		if (invites.existsPendingByCoachIdAndEmail(account.getId(), email, now)) {
			throw new ApiException(HttpStatus.CONFLICT, "INVITE_ALREADY_PENDING");
		}
		boolean alreadyClient = users.findByEmail(email)
			.flatMap(user -> links.findCurrentByCoachIdAndClientId(account.getId(), user.getId()))
			.isPresent();
		if (alreadyClient) {
			throw new ApiException(HttpStatus.CONFLICT, "ALREADY_YOUR_CLIENT");
		}
		CoachInvite invite = new CoachInvite();
		invite.setCoachId(account.getId());
		invite.setLabel(name);
		invite.setEmail(email);
		invite.setStatus(InviteStatus.PENDING);
		String code = assignNewCode(invite, now);
		return linkResponse(invites.save(invite), code);
	}

	/** Gives a pending (possibly expired) invite a new code and a new 7-day validity; the old code stops working. */
	@Transactional
	public InvitationLinkResponse regenerate(CurrentUser coach, UUID inviteId) {
		requireVerifiedCoach(coach);
		CoachInvite invite = requirePendingOwnInvite(coach, inviteId);
		String code = assignNewCode(invite, clock.instant());
		return linkResponse(invites.save(invite), code);
	}

	/** Cancels a pending (possibly expired) invite. */
	@Transactional
	public void cancel(CurrentUser coach, UUID inviteId) {
		CoachInvite invite = requirePendingOwnInvite(coach, inviteId);
		invite.setStatus(InviteStatus.REVOKED);
		invites.save(invite);
	}

	@Transactional(readOnly = true)
	public InvitePreviewResponse preview(String code, String ip) {
		rateLimiter.hit("invite-ip", ip, limits.inviteIp().limit());
		CoachInvite invite = find(code);
		requireUsable(invite);
		AppUser coach = requireAvailableCoach(invite);
		return new InvitePreviewResponse(coach.getFirstName(), coach.getLastName(), true);
	}

	/** Locks and returns the usable invite for the code; the caller must mark it used in the same transaction. */
	@Transactional(propagation = Propagation.MANDATORY)
	public CoachInvite claim(String code) {
		String normalized = InviteCodes.normalize(code);
		if (normalized.isEmpty()) {
			throw new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND");
		}
		CoachInvite invite = invites.findByCodeHashForUpdate(TokenHasher.sha256(normalized))
			.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND"));
		requireUsable(invite);
		requireAvailableCoach(invite);
		return invite;
	}

	@Transactional(propagation = Propagation.MANDATORY)
	public void markUsed(CoachInvite invite, UUID clientId) {
		invite.setStatus(InviteStatus.USED);
		invite.setUsedAt(clock.instant());
		invite.setUsedByClientId(clientId);
		invites.save(invite);
	}

	void requireUsable(CoachInvite invite) {
		switch (invite.getStatus()) {
			case USED -> throw new ApiException(HttpStatus.GONE, "INVITE_USED");
			case REVOKED -> throw new ApiException(HttpStatus.GONE, "INVITE_REVOKED");
			case PENDING -> {
				if (!invite.getExpiresAt().isAfter(clock.instant())) {
					throw new ApiException(HttpStatus.GONE, "INVITE_EXPIRED");
				}
			}
		}
	}

	/** Invites stay valid while their coach is suspended, but cannot be used until the coach is ACTIVE again. */
	private AppUser requireAvailableCoach(CoachInvite invite) {
		AppUser coach = users.findById(invite.getCoachId())
			.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND"));
		if (coach.getStatus() != UserStatus.ACTIVE) {
			throw new ApiException(HttpStatus.CONFLICT, "COACH_UNAVAILABLE");
		}
		return coach;
	}

	private CoachInvite find(String code) {
		String normalized = InviteCodes.normalize(code);
		if (normalized.isEmpty()) {
			throw new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND");
		}
		return invites.findByCodeHash(TokenHasher.sha256(normalized))
			.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND"));
	}

	private AppUser requireVerifiedCoach(CurrentUser coach) {
		AppUser account = accounts.require(coach);
		if (account.getStatus() != UserStatus.ACTIVE) {
			throw new ApiException(HttpStatus.FORBIDDEN, "EMAIL_NOT_VERIFIED");
		}
		return account;
	}

	private CoachInvite requirePendingOwnInvite(CurrentUser coach, UUID inviteId) {
		CoachInvite invite = invites.findByIdAndCoachIdForUpdate(inviteId, coach.id())
			.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND"));
		if (invite.getStatus() != InviteStatus.PENDING) {
			throw new ApiException(HttpStatus.CONFLICT, "INVITE_NOT_PENDING");
		}
		return invite;
	}

	/** Sets a new unique code hash and expiry on the invite and returns the plain code (normalized form). */
	private String assignNewCode(CoachInvite invite, Instant now) {
		for (int attempt = 0; attempt < MAX_GENERATION_ATTEMPTS; attempt++) {
			String code = InviteCodes.generate();
			String hash = TokenHasher.sha256(code);
			if (invites.findByCodeHash(hash).isPresent()) {
				continue;
			}
			invite.setCodeHash(hash);
			invite.setExpiresAt(now.plus(VALIDITY));
			return code;
		}
		throw new IllegalStateException("Could not generate a unique invite code");
	}

	private InvitationLinkResponse linkResponse(CoachInvite invite, String code) {
		String display = InviteCodes.display(code);
		return new InvitationLinkResponse(invite.getId(), invite.getLabel(), invite.getEmail(), display,
				app.baseUrlWithoutTrailingSlash() + "/join/" + display, invite.getExpiresAt());
	}

}
