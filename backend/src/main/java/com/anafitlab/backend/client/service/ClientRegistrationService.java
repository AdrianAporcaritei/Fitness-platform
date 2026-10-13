package com.anafitlab.backend.client.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.dto.TokenResponse;
import com.anafitlab.backend.auth.entity.ActionTokenPurpose;
import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.service.AccountEmails;
import com.anafitlab.backend.auth.service.ActionTokenService;
import com.anafitlab.backend.auth.service.SessionFactory;
import com.anafitlab.backend.auth.service.UserRegistrar;
import com.anafitlab.backend.client.dto.RegisterClientRequest;
import com.anafitlab.backend.client.entity.CoachInvite;
import com.anafitlab.backend.common.ratelimit.RateLimitProperties;
import com.anafitlab.backend.common.ratelimit.RateLimiter;

@Service
public class ClientRegistrationService {

	private final RateLimiter rateLimiter;
	private final RateLimitProperties limits;
	private final InviteService invites;
	private final UserRegistrar registrar;
	private final CoachLinkService coachLinks;
	private final ActionTokenService actionTokens;
	private final AccountEmails emails;
	private final SessionFactory sessions;

	ClientRegistrationService(RateLimiter rateLimiter, RateLimitProperties limits, InviteService invites,
			UserRegistrar registrar, CoachLinkService coachLinks, ActionTokenService actionTokens,
			AccountEmails emails, SessionFactory sessions) {
		this.rateLimiter = rateLimiter;
		this.limits = limits;
		this.invites = invites;
		this.registrar = registrar;
		this.coachLinks = coachLinks;
		this.actionTokens = actionTokens;
		this.emails = emails;
		this.sessions = sessions;
	}

	/** One transaction: any failure leaves the invite PENDING and creates no account. */
	@Transactional
	public TokenResponse register(RegisterClientRequest request, String ip) {
		rateLimiter.hit("signup-ip", ip, limits.signupIp().limit());
		CoachInvite invite = invites.claim(request.code());
		AppUser user = registrar.register(Role.CLIENT, request.toNewUser());
		coachLinks.link(invite, user.getId());
		String rawToken = actionTokens.issue(user, ActionTokenPurpose.EMAIL_VERIFICATION);
		emails.sendVerification(user, rawToken);
		return sessions.create(user);
	}

}
