package com.anafitlab.backend.client.dto;

/** Status of a row in the coach's client list: INVITED comes from a pending invite, the rest from coach_client. */
public enum ClientListStatus {
	INVITED, ACTIVE, PAUSED, ENDED
}
