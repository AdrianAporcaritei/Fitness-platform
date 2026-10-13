package com.anafitlab.backend.client.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "coach_invite")
public class CoachInvite {

	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Column(name = "coach_id")
	private UUID coachId;

	@Column(name = "code_hash")
	private String codeHash;

	@Column(name = "label")
	private String label;

	@Column(name = "email")
	private String email;

	@Enumerated(EnumType.STRING)
	@Column(name = "status")
	private InviteStatus status;

	@Column(name = "expires_at")
	private Instant expiresAt;

	@Column(name = "used_at")
	private Instant usedAt;

	@Column(name = "used_by_client_id")
	private UUID usedByClientId;

	@CreationTimestamp
	@Column(name = "created_at", nullable = false, updatable = false)
	private Instant createdAt;

	@UpdateTimestamp
	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt;

	public UUID getId() {
		return id;
	}

	public UUID getCoachId() {
		return coachId;
	}

	public void setCoachId(UUID coachId) {
		this.coachId = coachId;
	}

	public String getCodeHash() {
		return codeHash;
	}

	public void setCodeHash(String codeHash) {
		this.codeHash = codeHash;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public InviteStatus getStatus() {
		return status;
	}

	public void setStatus(InviteStatus status) {
		this.status = status;
	}

	public Instant getExpiresAt() {
		return expiresAt;
	}

	public void setExpiresAt(Instant expiresAt) {
		this.expiresAt = expiresAt;
	}

	public Instant getUsedAt() {
		return usedAt;
	}

	public void setUsedAt(Instant usedAt) {
		this.usedAt = usedAt;
	}

	public UUID getUsedByClientId() {
		return usedByClientId;
	}

	public void setUsedByClientId(UUID usedByClientId) {
		this.usedByClientId = usedByClientId;
	}

	public Instant getCreatedAt() {
		return createdAt;
	}

	public Instant getUpdatedAt() {
		return updatedAt;
	}

}
