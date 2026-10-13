package com.anafitlab.backend.client;

import java.time.Clock;
import java.time.Instant;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.client.dto.ClientListItem;
import com.anafitlab.backend.client.dto.ClientListPage;
import com.anafitlab.backend.common.security.CurrentUser;

@Service
public class ClientListService {

	private final ClientListQuery query;
	private final Clock clock;

	ClientListService(ClientListQuery query, Clock clock) {
		this.query = query;
		this.clock = clock;
	}

	/** The authenticated coach's own invited and linked clients; see {@link ClientListQuery}. */
	@Transactional(readOnly = true)
	public ClientListPage list(CurrentUser coach, ClientListStatus status, String search, int page, int size) {
		ClientListQuery.Result result = query.find(coach.id(), status, search, page, size);
		Instant now = clock.instant();
		var items = result.rows().stream()
			.map(r -> new ClientListItem(r.id(), r.name(), r.email(), r.status(), r.invitedAt(),
					r.invitationExpiresAt(),
					r.invitationExpiresAt() != null && !r.invitationExpiresAt().isAfter(now)))
			.toList();
		int totalPages = (int) ((result.total() + size - 1) / size);
		return new ClientListPage(items, page, size, result.total(), totalPages);
	}

}
