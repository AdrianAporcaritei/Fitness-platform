package com.anafitlab.backend.client.dto;

import java.time.Instant;
import java.util.UUID;

import com.anafitlab.backend.client.RelationshipStatus;

public record CoachClientResponse(UUID clientId, String firstName, String lastName, String email,
		RelationshipStatus status, Instant startedAt) {
}
