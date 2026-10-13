package com.anafitlab.backend.client.service;

import static com.anafitlab.backend.client.entity.RelationshipStatus.ACTIVE;
import static com.anafitlab.backend.client.entity.RelationshipStatus.ENDED;
import static com.anafitlab.backend.client.entity.RelationshipStatus.PAUSED;

import org.springframework.http.HttpStatus;

import com.anafitlab.backend.client.entity.RelationshipStatus;
import com.anafitlab.backend.common.error.ApiException;

public final class RelationshipTransitions {

	private RelationshipTransitions() {
	}

	public static void require(RelationshipStatus from, RelationshipStatus to) {
		boolean allowed = (from == ACTIVE && (to == PAUSED || to == ENDED))
				|| (from == PAUSED && (to == ACTIVE || to == ENDED));
		if (!allowed) {
			throw new ApiException(HttpStatus.CONFLICT, "INVALID_RELATIONSHIP_TRANSITION");
		}
	}

}
