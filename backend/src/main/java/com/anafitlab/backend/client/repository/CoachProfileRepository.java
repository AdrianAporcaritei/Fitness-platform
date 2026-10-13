package com.anafitlab.backend.client.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.anafitlab.backend.client.entity.CoachProfile;

public interface CoachProfileRepository extends JpaRepository<CoachProfile, UUID> {

}
