package com.anafitlab.backend.common.error;

import java.util.Optional;
import java.util.UUID;

/** Supplies a user's preferred locale ({@code ro} or {@code en}) so error messages can match it. */
public interface UserLocaleLookup {

	Optional<String> localeOf(UUID userId);

}
