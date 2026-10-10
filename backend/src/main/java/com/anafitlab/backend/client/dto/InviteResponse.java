package com.anafitlab.backend.client.dto;

import java.time.Instant;
import java.util.UUID;

public record InviteResponse(UUID id, String label, String status, Instant createdAt, Instant expiresAt,
		Instant usedAt) {
}
