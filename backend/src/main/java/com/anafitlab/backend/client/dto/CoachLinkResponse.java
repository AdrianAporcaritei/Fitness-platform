package com.anafitlab.backend.client.dto;

import java.time.Instant;
import java.util.UUID;

import com.anafitlab.backend.client.RelationshipStatus;

public record CoachLinkResponse(UUID coachId, String coachFirstName, String coachLastName, RelationshipStatus status,
		Instant startedAt) {
}
