package com.anafitlab.backend.client;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.client.dto.AddClientRequest;
import com.anafitlab.backend.client.dto.ChangeRelationshipRequest;
import com.anafitlab.backend.client.dto.ClientListPage;
import com.anafitlab.backend.client.dto.CoachClientResponse;
import com.anafitlab.backend.client.dto.InvitationLinkResponse;
import com.anafitlab.backend.common.security.CurrentUser;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

@RestController
class CoachClientController {

	private final ClientListService clientList;
	private final InviteService invites;
	private final RelationshipService relationships;

	CoachClientController(ClientListService clientList, InviteService invites, RelationshipService relationships) {
		this.clientList = clientList;
		this.invites = invites;
		this.relationships = relationships;
	}

	@GetMapping("/coach/clients")
	ClientListPage list(CurrentUser current,
			@RequestParam(required = false) @Size(max = 100, message = "TOO_LONG") String q,
			@RequestParam(required = false) ClientListStatus status,
			@RequestParam(defaultValue = "0") @Min(value = 0, message = "MIN") int page,
			@RequestParam(defaultValue = "20") @Min(value = 1, message = "MIN") @Max(value = 100, message = "MAX") int size) {
		return clientList.list(current, status, q, page, size);
	}

	@PostMapping("/coach/clients")
	@ResponseStatus(HttpStatus.CREATED)
	InvitationLinkResponse add(CurrentUser current, @Valid @RequestBody AddClientRequest request) {
		return invites.create(current, request.name(), request.email());
	}

	@PatchMapping("/coach/clients/{clientId}/relationship")
	CoachClientResponse change(CurrentUser current, @PathVariable UUID clientId,
			@Valid @RequestBody ChangeRelationshipRequest request) {
		return relationships.changeStatus(current, clientId, request.status());
	}

}
