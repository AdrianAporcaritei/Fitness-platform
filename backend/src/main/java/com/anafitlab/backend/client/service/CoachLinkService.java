package com.anafitlab.backend.client.service;

import java.time.Clock;
import java.util.UUID;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.repository.AppUserRepository;
import com.anafitlab.backend.auth.service.CurrentUserAccounts;
import com.anafitlab.backend.client.dto.CoachLinkResponse;
import com.anafitlab.backend.client.entity.CoachClient;
import com.anafitlab.backend.client.entity.CoachInvite;
import com.anafitlab.backend.client.entity.RelationshipStatus;
import com.anafitlab.backend.client.repository.CoachClientRepository;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.error.ConstraintViolations;
import com.anafitlab.backend.common.ratelimit.RateLimitProperties;
import com.anafitlab.backend.common.ratelimit.RateLimiter;
import com.anafitlab.backend.common.security.CurrentUser;

@Service
public class CoachLinkService {

	private static final String CURRENT_COACH_CONSTRAINT = "ux_coach_client_current";

	private final CoachClientRepository links;
	private final InviteService invites;
	private final AppUserRepository users;
	private final CurrentUserAccounts accounts;
	private final RateLimiter rateLimiter;
	private final RateLimitProperties limits;
	private final Clock clock;

	CoachLinkService(CoachClientRepository links, InviteService invites, AppUserRepository users,
			CurrentUserAccounts accounts, RateLimiter rateLimiter, RateLimitProperties limits, Clock clock) {
		this.links = links;
		this.invites = invites;
		this.users = users;
		this.accounts = accounts;
		this.rateLimiter = rateLimiter;
		this.limits = limits;
		this.clock = clock;
	}

	/** Creates the ACTIVE relationship for a claimed invite and consumes the invite. */
	@Transactional(propagation = Propagation.MANDATORY)
	public CoachClient link(CoachInvite invite, UUID clientId) {
		if (links.findCurrentByClientId(clientId).isPresent()) {
			throw alreadyHasCoach();
		}
		CoachClient link = new CoachClient();
		link.setCoachId(invite.getCoachId());
		link.setClientId(clientId);
		link.setStatus(RelationshipStatus.ACTIVE);
		link.setInvitedAt(invite.getCreatedAt());
		link.setStartedAt(clock.instant());
		try {
			link = links.saveAndFlush(link);
		}
		catch (DataIntegrityViolationException e) {
			if (ConstraintViolations.violates(e, CURRENT_COACH_CONSTRAINT)) {
				throw alreadyHasCoach();
			}
			throw e;
		}
		invites.markUsed(invite, clientId);
		return link;
	}

	/** Links the authenticated client, who has no current coach, to the coach that issued the code. */
	@Transactional
	public CoachLinkResponse linkCurrentClient(CurrentUser current, String code, String ip) {
		rateLimiter.hit("invite-ip", ip, limits.inviteIp().limit());
		AppUser client = accounts.require(current);
		CoachInvite invite = invites.claim(code);
		CoachClient link = link(invite, client.getId());
		AppUser coach = users.findById(link.getCoachId())
			.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "INVITE_NOT_FOUND"));
		return new CoachLinkResponse(coach.getId(), coach.getFirstName(), coach.getLastName(), link.getStatus(),
				link.getStartedAt());
	}

	private static ApiException alreadyHasCoach() {
		return new ApiException(HttpStatus.CONFLICT, "ALREADY_HAS_COACH");
	}

}
