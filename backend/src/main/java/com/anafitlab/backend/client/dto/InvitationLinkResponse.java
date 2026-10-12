package com.anafitlab.backend.client.dto;

import java.time.Instant;
import java.util.UUID;

/** A freshly issued invitation code; the only response that ever carries the code. */
public record InvitationLinkResponse(UUID invitationId, String name, String email, String code, String link,
		Instant expiresAt) {
}
