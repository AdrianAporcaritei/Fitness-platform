package com.anafitlab.backend.client;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.anafitlab.backend.client.dto.CoachProfileResponse;
import com.anafitlab.backend.client.dto.UpdateCoachProfileRequest;
import com.anafitlab.backend.common.security.CurrentUser;

import jakarta.validation.Valid;

@RestController
class CoachProfileController {

	private final CoachProfileService profiles;

	CoachProfileController(CoachProfileService profiles) {
		this.profiles = profiles;
	}

	@GetMapping("/coach/profile")
	CoachProfileResponse get(CurrentUser current) {
		return profiles.get(current);
	}

	@PatchMapping("/coach/profile")
	CoachProfileResponse update(CurrentUser current, @Valid @RequestBody UpdateCoachProfileRequest request) {
		return profiles.update(current, request);
	}

}
