package com.anafitlab.backend.client.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.client.dto.CoachLinkRequest;
import com.anafitlab.backend.client.dto.CoachLinkResponse;
import com.anafitlab.backend.client.dto.MyCoachResponse;
import com.anafitlab.backend.client.service.CoachLinkService;
import com.anafitlab.backend.client.service.RelationshipService;
import com.anafitlab.backend.common.security.ClientIp;
import com.anafitlab.backend.common.security.CurrentUser;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
class MyCoachController {

	private final CoachLinkService coachLinks;
	private final RelationshipService relationships;

	MyCoachController(CoachLinkService coachLinks, RelationshipService relationships) {
		this.coachLinks = coachLinks;
		this.relationships = relationships;
	}

	@GetMapping("/me/coach")
	MyCoachResponse myCoach(CurrentUser current) {
		return relationships.myCoach(current);
	}

	@DeleteMapping("/me/coach")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	void leave(CurrentUser current) {
		relationships.leave(current);
	}

	@PostMapping("/me/coach-link")
	@ResponseStatus(HttpStatus.CREATED)
	CoachLinkResponse link(CurrentUser current, @Valid @RequestBody CoachLinkRequest request, HttpServletRequest http) {
		return coachLinks.linkCurrentClient(current, request.code(), ClientIp.of(http));
	}

}
