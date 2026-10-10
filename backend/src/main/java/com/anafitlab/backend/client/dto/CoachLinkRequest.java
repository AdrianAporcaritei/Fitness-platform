package com.anafitlab.backend.client.dto;

import jakarta.validation.constraints.NotBlank;

public record CoachLinkRequest(@NotBlank(message = "REQUIRED") String code) {
}
