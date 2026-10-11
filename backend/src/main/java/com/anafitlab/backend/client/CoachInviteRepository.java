package com.anafitlab.backend.client;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;

public interface CoachInviteRepository extends JpaRepository<CoachInvite, UUID> {

	Optional<CoachInvite> findByCodeHash(String codeHash);

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("SELECT i FROM CoachInvite i WHERE i.codeHash = :codeHash")
	Optional<CoachInvite> findByCodeHashForUpdate(@Param("codeHash") String codeHash);

	List<CoachInvite> findByCoachIdOrderByCreatedAtDesc(UUID coachId);

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("SELECT i FROM CoachInvite i WHERE i.id = :id AND i.coachId = :coachId")
	Optional<CoachInvite> findByIdAndCoachIdForUpdate(@Param("id") UUID id, @Param("coachId") UUID coachId);

}
