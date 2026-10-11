package com.anafitlab.backend.client;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.Role;
import com.anafitlab.backend.auth.UserStatus;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.security.CurrentUser;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.TestFixtures;

class ClientAccessPolicyIntegrationTest extends IntegrationTestBase {

	@Autowired
	private ClientAccessPolicy policy;

	@Autowired
	private TestFixtures fixtures;

	private CurrentUser as(AppUser u) {
		return new CurrentUser(u.getId(), u.getRole());
	}

	private void assertReadWrite(CurrentUser user, UUID clientId, boolean read, boolean write) {
		check(() -> policy.requireReadAccess(user, clientId), read);
		check(() -> policy.requireWriteAccess(user, clientId), write);
	}

	private void check(Runnable call, boolean allowed) {
		if (allowed) {
			assertThatCode(call::run).doesNotThrowAnyException();
		}
		else {
			assertThatThrownBy(call::run).isInstanceOfSatisfying(ApiException.class,
					e -> assertThat(e.code()).isEqualTo("CLIENT_NOT_FOUND"));
		}
	}

	@Test
	void matchesDatabaseState() {
		AppUser coachA = fixtures.user(Role.COACH, UserStatus.ACTIVE, "a@example.com");
		AppUser coachB = fixtures.user(Role.COACH, UserStatus.ACTIVE, "b@example.com");
		AppUser admin = fixtures.user(Role.ADMIN, UserStatus.ACTIVE, "admin@example.com");
		AppUser active = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "c1@example.com");
		AppUser paused = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "c2@example.com");
		AppUser ended = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "c3@example.com");
		fixtures.link(coachA, active, RelationshipStatus.ACTIVE);
		fixtures.link(coachA, paused, RelationshipStatus.PAUSED);
		fixtures.link(coachA, ended, RelationshipStatus.ENDED);

		// coach A: ACTIVE read+write, PAUSED read only, ENDED none
		assertReadWrite(as(coachA), active.getId(), true, true);
		assertReadWrite(as(coachA), paused.getId(), true, false);
		assertReadWrite(as(coachA), ended.getId(), false, false);
		// coach B is unrelated to all of them
		assertReadWrite(as(coachB), active.getId(), false, false);
		assertReadWrite(as(coachB), paused.getId(), false, false);
		// clients: own id passes, someone else's fails
		assertReadWrite(as(active), active.getId(), true, true);
		assertReadWrite(as(active), paused.getId(), false, false);
		// admin never
		assertReadWrite(as(admin), active.getId(), false, false);
		// nonexistent client id behaves like an inaccessible one
		assertReadWrite(as(coachA), UUID.randomUUID(), false, false);
	}

}
