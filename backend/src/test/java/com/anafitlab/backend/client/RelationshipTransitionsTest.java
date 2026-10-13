package com.anafitlab.backend.client;

import static com.anafitlab.backend.client.entity.RelationshipStatus.ACTIVE;
import static com.anafitlab.backend.client.entity.RelationshipStatus.ENDED;
import static com.anafitlab.backend.client.entity.RelationshipStatus.PAUSED;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;

import com.anafitlab.backend.client.entity.RelationshipStatus;
import com.anafitlab.backend.client.service.RelationshipTransitions;
import com.anafitlab.backend.common.error.ApiException;

class RelationshipTransitionsTest {

	@Test
	void allowedTransitionsPass() {
		assertThatCode(() -> RelationshipTransitions.require(ACTIVE, PAUSED)).doesNotThrowAnyException();
		assertThatCode(() -> RelationshipTransitions.require(PAUSED, ACTIVE)).doesNotThrowAnyException();
		assertThatCode(() -> RelationshipTransitions.require(ACTIVE, ENDED)).doesNotThrowAnyException();
		assertThatCode(() -> RelationshipTransitions.require(PAUSED, ENDED)).doesNotThrowAnyException();
	}

	@Test
	void otherTransitionsThrow() {
		assertRejected(ENDED, ACTIVE);
		assertRejected(ENDED, PAUSED);
		assertRejected(ACTIVE, ACTIVE);
		assertRejected(PAUSED, PAUSED);
	}

	private void assertRejected(RelationshipStatus from, RelationshipStatus to) {
		assertThatThrownBy(() -> RelationshipTransitions.require(from, to)).isInstanceOfSatisfying(ApiException.class,
				e -> assertThat(e.code()).isEqualTo("INVALID_RELATIONSHIP_TRANSITION"));
	}

}
