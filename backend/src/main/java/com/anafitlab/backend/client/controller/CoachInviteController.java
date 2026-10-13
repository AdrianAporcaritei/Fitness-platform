package com.anafitlab.backend.client.controller;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.client.dto.InvitationLinkResponse;
import com.anafitlab.backend.client.service.InviteService;
import com.anafitlab.backend.common.security.CurrentUser;

@RestController
class CoachInviteController {

	private final InviteService invites;

	CoachInviteController(InviteService invites) {
		this.invites = invites;
	}

	@PostMapping("/coach/invites/{id}/regenerate")
	InvitationLinkResponse regenerate(CurrentUser coach, @PathVariable UUID id) {
		return invites.regenerate(coach, id);
	}

	@DeleteMapping("/coach/invites/{id}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	void cancel(CurrentUser coach, @PathVariable UUID id) {
		invites.cancel(coach, id);
	}

}
