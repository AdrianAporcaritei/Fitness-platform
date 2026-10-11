package com.anafitlab.backend.client;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.client.dto.InvitePreviewResponse;
import com.anafitlab.backend.common.security.ClientIp;

import jakarta.servlet.http.HttpServletRequest;

@RestController
class InviteController {

	private final InviteService invites;

	InviteController(InviteService invites) {
		this.invites = invites;
	}

	@GetMapping("/invites/{code}")
	InvitePreviewResponse preview(@PathVariable String code, HttpServletRequest http) {
		return invites.preview(code, ClientIp.of(http));
	}

}
