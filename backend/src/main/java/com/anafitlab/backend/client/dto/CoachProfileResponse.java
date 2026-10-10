package com.anafitlab.backend.client.dto;

import java.util.List;

public record CoachProfileResponse(String bio, List<String> specializations) {
}
