package com.anafitlab.backend.auth;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;

public interface UserActionTokenRepository extends JpaRepository<UserActionToken, UUID> {

	Optional<UserActionToken> findByTokenHashAndPurpose(String tokenHash, ActionTokenPurpose purpose);

	/** Row-locking lookup for consuming a token, so concurrent consumers are serialized. */
	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("SELECT t FROM UserActionToken t WHERE t.tokenHash = :tokenHash AND t.purpose = :purpose")
	Optional<UserActionToken> lockByTokenHashAndPurpose(@Param("tokenHash") String tokenHash,
			@Param("purpose") ActionTokenPurpose purpose);

	@Modifying(clearAutomatically = true, flushAutomatically = true)
	@Query("""
			UPDATE UserActionToken t SET t.usedAt = :now, t.updatedAt = :now
			WHERE t.userId = :userId AND t.purpose = :purpose AND t.usedAt IS NULL
			""")
	int invalidateUnused(@Param("userId") UUID userId, @Param("purpose") ActionTokenPurpose purpose,
			@Param("now") Instant now);

}
