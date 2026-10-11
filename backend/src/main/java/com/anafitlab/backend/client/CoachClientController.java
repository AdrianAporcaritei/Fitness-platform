package com.anafitlab.backend.client;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.client.dto.ChangeRelationshipRequest;
import com.anafitlab.backend.client.dto.CoachClientResponse;
import com.anafitlab.backend.common.security.CurrentUser;

import jakarta.validation.Valid;

@RestController
class CoachClientController {

	private final RelationshipService relationships;

	CoachClientController(RelationshipService relationships) {
		this.relationships = relationships;
	}

	@GetMapping("/coach/clients")
	List<CoachClientResponse> list(CurrentUser current) {
		return relationships.listClients(current);
	}

	@PatchMapping("/coach/clients/{clientId}/relationship")
	CoachClientResponse change(CurrentUser current, @PathVariable UUID clientId,
			@Valid @RequestBody ChangeRelationshipRequest request) {
		return relationships.changeStatus(current, clientId, request.status());
	}

}
