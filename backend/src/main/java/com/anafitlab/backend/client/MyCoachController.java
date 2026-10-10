package com.anafitlab.backend.client;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.client.dto.CoachLinkRequest;
import com.anafitlab.backend.client.dto.CoachLinkResponse;
import com.anafitlab.backend.common.security.ClientIp;
import com.anafitlab.backend.common.security.CurrentUser;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
class MyCoachController {

	private final CoachLinkService coachLinks;

	MyCoachController(CoachLinkService coachLinks) {
		this.coachLinks = coachLinks;
	}

	@PostMapping("/me/coach-link")
	@ResponseStatus(HttpStatus.CREATED)
	CoachLinkResponse link(CurrentUser current, @Valid @RequestBody CoachLinkRequest request, HttpServletRequest http) {
		return coachLinks.linkCurrentClient(current, request.code(), ClientIp.of(http));
	}

}
