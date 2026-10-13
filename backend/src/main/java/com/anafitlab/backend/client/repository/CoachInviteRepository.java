package com.anafitlab.backend.client.repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.anafitlab.backend.client.entity.CoachInvite;

import jakarta.persistence.LockModeType;

public interface CoachInviteRepository extends JpaRepository<CoachInvite, UUID> {

	Optional<CoachInvite> findByCodeHash(String codeHash);

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("SELECT i FROM CoachInvite i WHERE i.codeHash = :codeHash")
	Optional<CoachInvite> findByCodeHashForUpdate(@Param("codeHash") String codeHash);

	@Query("SELECT count(i) > 0 FROM CoachInvite i WHERE i.coachId = :coachId AND i.email = :email AND i.status = com.anafitlab.backend.client.entity.InviteStatus.PENDING AND i.expiresAt > :now")
	boolean existsPendingByCoachIdAndEmail(@Param("coachId") UUID coachId, @Param("email") String email,
			@Param("now") Instant now);

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("SELECT i FROM CoachInvite i WHERE i.id = :id AND i.coachId = :coachId")
	Optional<CoachInvite> findByIdAndCoachIdForUpdate(@Param("id") UUID id, @Param("coachId") UUID coachId);

}
