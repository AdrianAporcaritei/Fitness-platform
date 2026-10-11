package com.anafitlab.backend.client;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.client.dto.CreateInviteRequest;
import com.anafitlab.backend.client.dto.CreatedInviteResponse;
import com.anafitlab.backend.client.dto.InviteResponse;
import com.anafitlab.backend.common.security.CurrentUser;

import jakarta.validation.Valid;

@RestController
class CoachInviteController {

	private final InviteService invites;

	CoachInviteController(InviteService invites) {
		this.invites = invites;
	}

	@PostMapping("/coach/invites")
	@ResponseStatus(HttpStatus.CREATED)
	CreatedInviteResponse create(CurrentUser coach, @Valid @RequestBody(required = false) CreateInviteRequest request) {
		return invites.create(coach, request == null ? null : request.label());
	}

	@GetMapping("/coach/invites")
	List<InviteResponse> list(CurrentUser coach) {
		return invites.list(coach);
	}

	@PostMapping("/coach/invites/{id}/revoke")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	void revoke(CurrentUser coach, @PathVariable UUID id) {
		invites.revoke(coach, id);
	}

}
