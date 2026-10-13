package com.anafitlab.backend.client.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.anafitlab.backend.client.entity.CoachClient;

import jakarta.persistence.LockModeType;

public interface CoachClientRepository extends JpaRepository<CoachClient, UUID> {

	@Query("SELECT c FROM CoachClient c WHERE c.clientId = :clientId AND c.status IN (com.anafitlab.backend.client.entity.RelationshipStatus.ACTIVE, com.anafitlab.backend.client.entity.RelationshipStatus.PAUSED)")
	Optional<CoachClient> findCurrentByClientId(@Param("clientId") UUID clientId);

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("SELECT c FROM CoachClient c WHERE c.clientId = :clientId AND c.status IN (com.anafitlab.backend.client.entity.RelationshipStatus.ACTIVE, com.anafitlab.backend.client.entity.RelationshipStatus.PAUSED)")
	Optional<CoachClient> findCurrentByClientIdForUpdate(@Param("clientId") UUID clientId);

	@Query("SELECT c FROM CoachClient c WHERE c.coachId = :coachId AND c.clientId = :clientId AND c.status IN (com.anafitlab.backend.client.entity.RelationshipStatus.ACTIVE, com.anafitlab.backend.client.entity.RelationshipStatus.PAUSED)")
	Optional<CoachClient> findCurrentByCoachIdAndClientId(@Param("coachId") UUID coachId,
			@Param("clientId") UUID clientId);

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("SELECT c FROM CoachClient c WHERE c.coachId = :coachId AND c.clientId = :clientId AND c.status IN (com.anafitlab.backend.client.entity.RelationshipStatus.ACTIVE, com.anafitlab.backend.client.entity.RelationshipStatus.PAUSED)")
	Optional<CoachClient> findCurrentByCoachIdAndClientIdForUpdate(@Param("coachId") UUID coachId,
			@Param("clientId") UUID clientId);

}
