package com.anafitlab.backend.auth.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;

public interface AppUserRepository extends JpaRepository<AppUser, UUID> {

	Optional<AppUser> findByEmail(String normalizedEmail);

	boolean existsByEmail(String email);

	boolean existsByRole(Role role);

}
