package com.anafitlab.backend;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.support.TransactionTemplate;

import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.AppUserRepository;
import com.anafitlab.backend.auth.RefreshToken;
import com.anafitlab.backend.auth.RefreshTokenRepository;
import com.anafitlab.backend.auth.Role;
import com.anafitlab.backend.auth.UserStatus;
import com.anafitlab.backend.client.CoachClientRepository;
import com.anafitlab.backend.client.CoachProfile;
import com.anafitlab.backend.client.CoachProfileRepository;
import com.anafitlab.backend.client.RelationshipStatus;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.TestFixtures;

class RepositoriesTest extends IntegrationTestBase {

	@Autowired TestFixtures fixtures;
	@Autowired AppUserRepository users;
	@Autowired CoachClientRepository links;
	@Autowired CoachProfileRepository profiles;
	@Autowired RefreshTokenRepository tokens;
	@Autowired TransactionTemplate tx;

	@Test
	void userQueriesAndCurrentLinks() {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.ro");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "client@x.ro");
		fixtures.link(coach, client, RelationshipStatus.ENDED);
		assertThat(links.findCurrentByClientId(client.getId())).isEmpty();
		fixtures.link(coach, client, RelationshipStatus.PAUSED);

		assertThat(users.findByEmail("coach@x.ro")).isPresent();
		assertThat(users.existsByEmail("nobody@x.ro")).isFalse();
		assertThat(users.existsByRole(Role.ADMIN)).isFalse();
		assertThat(links.findCurrentByClientId(client.getId())).isPresent();
		assertThat(links.findCurrentByCoachId(coach.getId())).hasSize(1);
		assertThat(links.findCurrentByCoachIdAndClientId(coach.getId(), client.getId())).isPresent();
	}

	@Test
	void coachProfileRoundTripsTextArray() {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.ro");
		CoachProfile p = new CoachProfile();
		p.setUserId(coach.getId());
		p.setSpecializations(List.of("strength", "nutrition"));
		profiles.saveAndFlush(p);
		assertThat(profiles.findById(coach.getId()).orElseThrow().getSpecializations())
				.containsExactly("strength", "nutrition");
	}

	@Test
	void revokeQueriesOnlyTouchUnrevokedRows() {
		AppUser u = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "client@x.ro");
		UUID fam1 = UUID.randomUUID();
		UUID fam2 = UUID.randomUUID();
		save(u, "a", fam1);
		save(u, "b", fam2);
		Instant now = Instant.now();
		assertThat(revoked(() -> tokens.revokeAllForUserExceptFamily(u.getId(), fam1, now))).isEqualTo(1);
		assertThat(revoked(() -> tokens.revokeFamily(fam2, now))).isZero();
		assertThat(revoked(() -> tokens.revokeAllForUser(u.getId(), now))).isEqualTo(1);
	}

	private int revoked(java.util.function.IntSupplier op) {
		return tx.execute(s -> op.getAsInt());
	}

	private void save(AppUser u, String hash, UUID family) {
		RefreshToken t = new RefreshToken();
		t.setUserId(u.getId());
		t.setTokenHash(hash);
		t.setFamilyId(family);
		t.setExpiresAt(Instant.now().plusSeconds(3600));
		tokens.save(t);
	}

}
