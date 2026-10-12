package com.anafitlab.backend.client.dto;

import java.time.Instant;
import java.util.UUID;

import com.anafitlab.backend.client.ClientListStatus;

/** A row of the coach's client list: the invitation id for INVITED rows, otherwise the client's user id. */
public record ClientListItem(UUID id, String name, String email, ClientListStatus status, Instant invitedAt,
		Instant invitationExpiresAt, boolean invitationExpired) {
}
