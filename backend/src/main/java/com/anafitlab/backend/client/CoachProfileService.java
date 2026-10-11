package com.anafitlab.backend.client;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.CurrentUserAccounts;
import com.anafitlab.backend.client.dto.CoachProfileResponse;
import com.anafitlab.backend.client.dto.UpdateCoachProfileRequest;
import com.anafitlab.backend.common.security.CurrentUser;

@Service
public class CoachProfileService {

	private final CoachProfileRepository profiles;
	private final CurrentUserAccounts accounts;

	CoachProfileService(CoachProfileRepository profiles, CurrentUserAccounts accounts) {
		this.profiles = profiles;
		this.accounts = accounts;
	}

	/** A coach without a profile row reads as an empty profile; the row is created on first update. */
	@Transactional(readOnly = true)
	public CoachProfileResponse get(CurrentUser coach) {
		return profiles.findById(coach.id()).map(CoachProfileService::toResponse)
				.orElseGet(() -> new CoachProfileResponse(null, List.of()));
	}

	@Transactional
	public CoachProfileResponse update(CurrentUser coach, UpdateCoachProfileRequest request) {
		accounts.require(coach);
		CoachProfile profile = profiles.findById(coach.id()).orElseGet(() -> {
			CoachProfile created = new CoachProfile();
			created.setUserId(coach.id());
			created.setSpecializations(List.of());
			return created;
		});
		if (request.bio() != null) {
			profile.setBio(request.bio());
		}
		if (request.specializations() != null) {
			profile.setSpecializations(List.copyOf(request.specializations()));
		}
		return toResponse(profiles.save(profile));
	}

	private static CoachProfileResponse toResponse(CoachProfile profile) {
		return new CoachProfileResponse(profile.getBio(), List.copyOf(profile.getSpecializations()));
	}

}
