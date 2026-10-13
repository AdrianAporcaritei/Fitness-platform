package com.anafitlab.backend.client.dto;

import java.util.List;

public record ClientListPage(List<ClientListItem> items, int page, int size, long totalItems, int totalPages) {
}
