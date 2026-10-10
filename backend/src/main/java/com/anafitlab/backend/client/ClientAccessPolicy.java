package com.anafitlab.backend.client;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.security.CurrentUser;

/**
 * Authorization check for access to a client's data. Every feature that reads or writes client-owned
 * data (measurements, plans, chat, ...) must call this before touching the data.
 *
 * <p>The policy looks only at the caller and the coach-client relationship, never at the client's user
 * row, so a client id that does not exist is indistinguishable from one the caller may not access.
 */
@Component
public class ClientAccessPolicy {

	private final CoachClientRepository relationships;

	public ClientAccessPolicy(CoachClientRepository relationships) {
		this.relationships = relationships;
	}

	/**
	 * Passes when the caller is the CLIENT with this id (no database call), or a COACH with a current
	 * (ACTIVE or PAUSED) relationship to the client. ADMIN never passes.
	 *
	 * @throws ApiException 404 {@code CLIENT_NOT_FOUND} on any failure, so that the existence of the
	 *         client is not revealed to callers without access
	 */
	public void requireReadAccess(CurrentUser user, UUID clientId) {
		if (!canRead(user, clientId)) {
			throw notFound();
		}
	}

	/**
	 * Like {@link #requireReadAccess}, but a COACH needs an ACTIVE relationship: a PAUSED one is
	 * read-only. A CLIENT can write only to their own data; ADMIN never passes.
	 *
	 * @throws ApiException 404 {@code CLIENT_NOT_FOUND} on any failure, so that the existence of the
	 *         client is not revealed to callers without access
	 */
	public void requireWriteAccess(CurrentUser user, UUID clientId) {
		if (!canWrite(user, clientId)) {
			throw notFound();
		}
	}

	private boolean canRead(CurrentUser user, UUID clientId) {
		return switch (user.role()) {
			case CLIENT -> user.id().equals(clientId);
			case COACH -> relationships.findCurrentByCoachIdAndClientId(user.id(), clientId).isPresent();
			case ADMIN -> false;
		};
	}

	private boolean canWrite(CurrentUser user, UUID clientId) {
		return switch (user.role()) {
			case CLIENT -> user.id().equals(clientId);
			case COACH -> relationships.findCurrentByCoachIdAndClientId(user.id(), clientId)
					.filter(link -> link.getStatus() == RelationshipStatus.ACTIVE).isPresent();
			case ADMIN -> false;
		};
	}

	private static ApiException notFound() {
		return new ApiException(HttpStatus.NOT_FOUND, "CLIENT_NOT_FOUND");
	}

}
