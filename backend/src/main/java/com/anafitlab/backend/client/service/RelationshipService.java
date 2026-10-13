package com.anafitlab.backend.client.service;

import java.time.Clock;
import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.repository.AppUserRepository;
import com.anafitlab.backend.client.dto.CoachClientResponse;
import com.anafitlab.backend.client.dto.MyCoachResponse;
import com.anafitlab.backend.client.entity.CoachClient;
import com.anafitlab.backend.client.entity.CoachProfile;
import com.anafitlab.backend.client.entity.RelationshipStatus;
import com.anafitlab.backend.client.repository.CoachClientRepository;
import com.anafitlab.backend.client.repository.CoachProfileRepository;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.security.CurrentUser;

@Service
public class RelationshipService {

	private final CoachClientRepository links;
	private final AppUserRepository users;
	private final CoachProfileRepository profiles;
	private final Clock clock;

	RelationshipService(CoachClientRepository links, AppUserRepository users, CoachProfileRepository profiles,
			Clock clock) {
		this.links = links;
		this.users = users;
		this.profiles = profiles;
		this.clock = clock;
	}

	@Transactional
	public CoachClientResponse changeStatus(CurrentUser coach, UUID clientId, RelationshipStatus target) {
		CoachClient link = links.findCurrentByCoachIdAndClientIdForUpdate(coach.id(), clientId)
				.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "CLIENT_NOT_FOUND"));
		RelationshipTransitions.require(link.getStatus(), target);
		end(link, target);
		AppUser client = users.findById(clientId)
				.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "CLIENT_NOT_FOUND"));
		return toResponse(links.save(link), client);
	}

	@Transactional(readOnly = true)
	public MyCoachResponse myCoach(CurrentUser client) {
		CoachClient link = currentLink(client);
		AppUser coach = users.findById(link.getCoachId())
				.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "NO_COACH"));
		CoachProfile profile = profiles.findById(coach.getId()).orElse(null);
		return new MyCoachResponse(coach.getId(), coach.getFirstName(), coach.getLastName(),
				profile == null ? null : profile.getBio(),
				profile == null ? List.of() : List.copyOf(profile.getSpecializations()), link.getStatus(),
				link.getStartedAt());
	}

	@Transactional
	public void leave(CurrentUser client) {
		CoachClient link = links.findCurrentByClientIdForUpdate(client.id())
				.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "NO_COACH"));
		RelationshipTransitions.require(link.getStatus(), RelationshipStatus.ENDED);
		end(link, RelationshipStatus.ENDED);
		links.save(link);
	}

	private CoachClient currentLink(CurrentUser client) {
		return links.findCurrentByClientId(client.id())
				.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "NO_COACH"));
	}

	private void end(CoachClient link, RelationshipStatus target) {
		link.setStatus(target);
		if (target == RelationshipStatus.ENDED) {
			link.setEndedAt(clock.instant());
		}
	}

	private static CoachClientResponse toResponse(CoachClient link, AppUser client) {
		return new CoachClientResponse(client.getId(), client.getFirstName(), client.getLastName(), client.getEmail(),
				link.getStatus(), link.getStartedAt());
	}

}
