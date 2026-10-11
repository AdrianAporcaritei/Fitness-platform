package com.anafitlab.backend.client.dto;

import jakarta.validation.constraints.Size;

public record CreateInviteRequest(@Size(max = 100, message = "TOO_LONG") String label) {
}
