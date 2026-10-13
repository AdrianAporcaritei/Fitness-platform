package com.anafitlab.backend.client;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.client.entity.CoachClient;
import com.anafitlab.backend.client.entity.RelationshipStatus;
import com.anafitlab.backend.client.repository.CoachClientRepository;
import com.anafitlab.backend.client.service.ClientAccessPolicy;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.security.CurrentUser;

class ClientAccessPolicyTest {

	private final CoachClientRepository repository = mock(CoachClientRepository.class);
	private final ClientAccessPolicy policy = new ClientAccessPolicy(repository);
	private final UUID coachId = UUID.randomUUID();
	private final UUID clientId = UUID.randomUUID();

	private void relationship(RelationshipStatus status) {
		CoachClient link = new CoachClient();
		link.setCoachId(coachId);
		link.setClientId(clientId);
		link.setStatus(status);
		when(repository.findCurrentByCoachIdAndClientId(coachId, clientId)).thenReturn(Optional.of(link));
	}

	private void noRelationship() {
		when(repository.findCurrentByCoachIdAndClientId(any(), any())).thenReturn(Optional.empty());
	}

	private void assertNotFound(Runnable call) {
		assertThatThrownBy(call::run).isInstanceOfSatisfying(ApiException.class, e -> {
			assertThat(e.status()).isEqualTo(HttpStatus.NOT_FOUND);
			assertThat(e.code()).isEqualTo("CLIENT_NOT_FOUND");
		});
	}

	@Test
	void clientSelfReadAndWritePassWithoutDatabaseCall() {
		CurrentUser self = new CurrentUser(clientId, Role.CLIENT);
		assertThatCode(() -> policy.requireReadAccess(self, clientId)).doesNotThrowAnyException();
		assertThatCode(() -> policy.requireWriteAccess(self, clientId)).doesNotThrowAnyException();
		verifyNoInteractions(repository);
	}

	@Test
	void clientOtherFails() {
		CurrentUser other = new CurrentUser(UUID.randomUUID(), Role.CLIENT);
		assertNotFound(() -> policy.requireReadAccess(other, clientId));
		assertNotFound(() -> policy.requireWriteAccess(other, clientId));
		verifyNoInteractions(repository);
	}

	@Test
	void coachActiveReadAndWritePass() {
		relationship(RelationshipStatus.ACTIVE);
		CurrentUser coach = new CurrentUser(coachId, Role.COACH);
		assertThatCode(() -> policy.requireReadAccess(coach, clientId)).doesNotThrowAnyException();
		assertThatCode(() -> policy.requireWriteAccess(coach, clientId)).doesNotThrowAnyException();
	}

	@Test
	void coachPausedReadPassesWriteFails() {
		relationship(RelationshipStatus.PAUSED);
		CurrentUser coach = new CurrentUser(coachId, Role.COACH);
		assertThatCode(() -> policy.requireReadAccess(coach, clientId)).doesNotThrowAnyException();
		assertNotFound(() -> policy.requireWriteAccess(coach, clientId));
	}

	@Test
	void coachEndedFails() {
		// ENDED is not "current": the repository returns nothing for it.
		noRelationship();
		CurrentUser coach = new CurrentUser(coachId, Role.COACH);
		assertNotFound(() -> policy.requireReadAccess(coach, clientId));
		assertNotFound(() -> policy.requireWriteAccess(coach, clientId));
	}

	@Test
	void coachUnrelatedFails() {
		noRelationship();
		CurrentUser coach = new CurrentUser(UUID.randomUUID(), Role.COACH);
		assertNotFound(() -> policy.requireReadAccess(coach, clientId));
		assertNotFound(() -> policy.requireWriteAccess(coach, clientId));
	}

	@Test
	void adminAlwaysFails() {
		CurrentUser admin = new CurrentUser(UUID.randomUUID(), Role.ADMIN);
		assertNotFound(() -> policy.requireReadAccess(admin, clientId));
		assertNotFound(() -> policy.requireWriteAccess(admin, clientId));
		verifyNoInteractions(repository);
	}

}
