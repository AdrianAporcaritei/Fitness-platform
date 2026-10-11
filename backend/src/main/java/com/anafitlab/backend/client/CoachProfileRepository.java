package com.anafitlab.backend.client;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

public interface CoachProfileRepository extends JpaRepository<CoachProfile, UUID> {

}
