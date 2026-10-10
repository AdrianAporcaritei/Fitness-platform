package com.anafitlab.backend.client.dto;

import java.time.Instant;
import java.util.UUID;

public record CreatedInviteResponse(UUID id, String code, String link, String label, Instant expiresAt) {
}
