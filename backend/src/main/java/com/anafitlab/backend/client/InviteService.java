package com.anafitlab.backend.client;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
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
import com.anafitlab.backend.client.dto.CreatedInviteResponse;
import com.anafitlab.backend.client.dto.InvitePreviewResponse;
import com.anafitlab.backend.client.dto.InviteResponse;
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
	private final AppUserRepository users;
	private final CurrentUserAccounts accounts;
	private final RateLimiter rateLimiter;
	private final RateLimitProperties limits;
	private final Clock clock;
	private final AppProperties app;

	InviteService(CoachInviteRepository invites, AppUserRepository users, CurrentUserAccounts accounts,
			RateLimiter rateLimiter, RateLimitProperties limits, Clock clock, AppProperties app) {
		this.invites = invites;
		this.users = users;
		this.accounts = accounts;
		this.rateLimiter = rateLimiter;
		this.limits = limits;
		this.clock = clock;
		this.app = app;
	}

	@Transactional
	public CreatedInviteResponse create(CurrentUser coach, String label) {
		AppUser account = accounts.require(coach);
		if (account.getStatus() != UserStatus.ACTIVE) {
			throw new ApiException(HttpStatus.FORBIDDEN, "EMAIL_NOT_VERIFIED");
		}
		for (int attempt = 0; attempt < MAX_GENERATION_ATTEMPTS; attempt++) {
			String code = InviteCodes.generate();
			String hash = TokenHasher.sha256(code);
			if (invites.findByCodeHash(hash).isPresent()) {
				continue;
			}
			CoachInvite invite = new CoachInvite();
			invite.setCoachId(account.getId());
			invite.setCodeHash(hash);
			invite.setLabel(label == null || label.isBlank() ? null : label.strip());
			invite.setStatus(InviteStatus.PENDING);
			invite.setExpiresAt(clock.instant().plus(VALIDITY));
			invite = invites.save(invite);
			String display = InviteCodes.display(code);
			return new CreatedInviteResponse(invite.getId(), display,
					app.baseUrlWithoutTrailingSlash() + "/join/" + display, invite.getLabel(), invite.getExpiresAt());
		}
		throw new IllegalStateException("Could not generate a unique invite code");
	}

	@Transactional(readOnly = true)
	public List<InviteResponse> list(CurrentUser coach) {
		Instant now = clock.instant();
		return invites.findByCoachIdOrderByCreatedAtDesc(coach.id()).stream()
			.map(i -> new InviteResponse(i.getId(), i.getLabel(), derivedStatus(i, now), i.getCreatedAt(),
					i.getExpiresAt(), i.getUsedAt()))
			.toList();
	}

	@Transactional
	public void revoke(CurrentUser coach, UUID inviteId) {
		CoachInvite invite = invites.findByIdAndCoachIdForUpdate(inviteId, coach.id())
			.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND"));
		if (!"PENDING".equals(derivedStatus(invite, clock.instant()))) {
			throw new ApiException(HttpStatus.CONFLICT, "INVITE_NOT_REVOCABLE");
		}
		invite.setStatus(InviteStatus.REVOKED);
		invites.save(invite);
	}

	@Transactional(readOnly = true)
	public InvitePreviewResponse preview(String code, String ip) {
		rateLimiter.hit("invite-ip", ip, limits.inviteIp().limit());
		CoachInvite invite = find(code);
		requireUsable(invite);
		AppUser coach = users.findById(invite.getCoachId())
			.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND"));
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

	private CoachInvite find(String code) {
		String normalized = InviteCodes.normalize(code);
		if (normalized.isEmpty()) {
			throw new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND");
		}
		return invites.findByCodeHash(TokenHasher.sha256(normalized))
			.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND"));
	}

	private static String derivedStatus(CoachInvite invite, Instant now) {
		if (invite.getStatus() == InviteStatus.PENDING && !invite.getExpiresAt().isAfter(now)) {
			return "EXPIRED";
		}
		return invite.getStatus().name();
	}

}
