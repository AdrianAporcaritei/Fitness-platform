package com.anafitlab.backend.client.dto;

import com.anafitlab.backend.client.RelationshipStatus;

import jakarta.validation.constraints.NotNull;

public record ChangeRelationshipRequest(@NotNull(message = "REQUIRED") RelationshipStatus status) {
}
