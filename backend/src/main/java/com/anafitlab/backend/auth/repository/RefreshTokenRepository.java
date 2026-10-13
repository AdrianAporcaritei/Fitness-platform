package com.anafitlab.backend.auth.repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.anafitlab.backend.auth.entity.RefreshToken;

import jakarta.persistence.LockModeType;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

	Optional<RefreshToken> findByTokenHash(String tokenHash);

	/** Row lock: concurrent rotations of one token are serialized, so exactly one can win. */
	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("SELECT t FROM RefreshToken t WHERE t.tokenHash = :tokenHash")
	Optional<RefreshToken> findByTokenHashForUpdate(@Param("tokenHash") String tokenHash);

	@Modifying(clearAutomatically = true, flushAutomatically = true)
	@Query("UPDATE RefreshToken t SET t.revokedAt = :now, t.updatedAt = :now WHERE t.familyId = :familyId AND t.revokedAt IS NULL")
	int revokeFamily(@Param("familyId") UUID familyId, @Param("now") Instant now);

	@Modifying(clearAutomatically = true, flushAutomatically = true)
	@Query("UPDATE RefreshToken t SET t.revokedAt = :now, t.updatedAt = :now WHERE t.userId = :userId AND t.revokedAt IS NULL")
	int revokeAllForUser(@Param("userId") UUID userId, @Param("now") Instant now);

	@Modifying(clearAutomatically = true, flushAutomatically = true)
	@Query("""
			UPDATE RefreshToken t SET t.revokedAt = :now, t.updatedAt = :now
			WHERE t.userId = :userId AND t.familyId <> :familyId AND t.revokedAt IS NULL
			""")
	int revokeAllForUserExceptFamily(@Param("userId") UUID userId, @Param("familyId") UUID familyId,
			@Param("now") Instant now);

}
