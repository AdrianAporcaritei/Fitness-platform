package com.anafitlab.backend.client.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.anafitlab.backend.client.entity.RelationshipStatus;

public record MyCoachResponse(UUID coachId, String firstName, String lastName, String bio,
		List<String> specializations, RelationshipStatus status, Instant startedAt) {
}
