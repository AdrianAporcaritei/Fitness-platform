package com.anafitlab.backend.auth.entity;

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
@Table(name = "user_action_token")
public class UserActionToken {

	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Column(name = "user_id")
	private UUID userId;

	@Enumerated(EnumType.STRING)
	@Column(name = "purpose")
	private ActionTokenPurpose purpose;

	@Column(name = "token_hash")
	private String tokenHash;

	@Column(name = "expires_at")
	private Instant expiresAt;

	@Column(name = "used_at")
	private Instant usedAt;

	@CreationTimestamp
	@Column(name = "created_at", nullable = false, updatable = false)
	private Instant createdAt;

	@UpdateTimestamp
	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt;

	public UUID getId() {
		return id;
	}

	public UUID getUserId() {
		return userId;
	}

	public void setUserId(UUID userId) {
		this.userId = userId;
	}

	public ActionTokenPurpose getPurpose() {
		return purpose;
	}

	public void setPurpose(ActionTokenPurpose purpose) {
		this.purpose = purpose;
	}

	public String getTokenHash() {
		return tokenHash;
	}

	public void setTokenHash(String tokenHash) {
		this.tokenHash = tokenHash;
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

	public Instant getCreatedAt() {
		return createdAt;
	}

	public Instant getUpdatedAt() {
		return updatedAt;
	}

}
