import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/router.dart';
import '../../../core/theme/tokens.dart';
import 'add_client_dialog.dart';
import 'client_list_query.dart';
import 'client_status_badge.dart';
import 'clients_repository.dart';
import 'confirm_dialog.dart';
import 'invitation_link_view.dart';

/// Below this width rows are shown as cards instead of a table.
const clientCardsBreakpoint = 600.0;

/// The coach's clients and pending invitations: search, status filter and
/// server-side paging, all kept in the URL ([query]).
class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key, required this.query});

  final ClientListQuery query;

  @override
  ConsumerState<ClientsPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends ConsumerState<ClientsPage> {
  static const _searchDelay = Duration(milliseconds: 300);

  late final _search = TextEditingController(text: widget.query.search);
  Timer? _debounce;

  /// A row action is running; further actions wait for it.
  bool _busy = false;

  @override
  void didUpdateWidget(ClientsPage old) {
    super.didUpdateWidget(old);
    // The URL changed from outside the field (clear filters, back button).
    if (widget.query.search != _search.text && _debounce?.isActive != true) {
      _search.text = widget.query.search;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _show(ClientListQuery query) {
    final params = query.toQueryParameters();
    context.go(
      Uri(
        path: Routes.coachClients,
        queryParameters: params.isEmpty ? null : params,
      ).toString(),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      if (mounted) _show(widget.query.withSearch(value));
    });
  }

  void _clearFilters() {
    _debounce?.cancel();
    _search.clear();
    _show(const ClientListQuery());
  }

  void _reload() => ref.invalidate(clientListProvider);

  /// An empty page after the last one (or after an emptied list).
  bool _isPastEnd(ClientListPage page) =>
      page.items.isEmpty &&
      widget.query.page > 0 &&
      widget.query.page >= page.totalPages;

  Future<void> _addClient() async {
    await showAddClientDialog(context);
    _reload();
  }

  Future<void> _regenerate(ClientListItem item) async {
    final l = AppLocalizations.of(context);
    final name = item.name ?? l.clientsNoName;
    final confirmed = await showConfirmDialog(
      context,
      title: l.regenerateConfirmTitle,
      body: l.regenerateConfirmBody(name),
      confirmLabel: l.regenerate,
      cancelLabel: l.cancel,
    );
    if (!confirmed || !mounted) return;
    await _runAction(() async {
      final renewed = await ref
          .read(clientsRepositoryProvider)
          .regenerate(item.id);
      if (mounted) await showInvitationLinkDialog(context, renewed);
    });
  }

  Future<void> _cancel(ClientListItem item) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l.cancelInvitationConfirmTitle,
      body: l.cancelInvitationConfirmBody(item.name ?? l.clientsNoName),
      confirmLabel: l.cancelInvitation,
      cancelLabel: l.keepInvitation,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _runAction(() async {
      await ref.read(clientsRepositoryProvider).cancel(item.id);
      _snack(l.invitationCancelled);
    });
  }

  Future<void> _pause(ClientListItem item) => _changeRelationship(
    item,
    ChangeRelationshipRequestStatus.paused,
    AppLocalizations.of(context).relationshipPaused,
  );

  Future<void> _resume(ClientListItem item) => _changeRelationship(
    item,
    ChangeRelationshipRequestStatus.active,
    AppLocalizations.of(context).relationshipResumed,
  );

  Future<void> _end(ClientListItem item) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l.endRelationshipConfirmTitle(item.name ?? l.clientsNoName),
      body: l.endRelationshipConfirmBody,
      confirmLabel: l.endRelationship,
      cancelLabel: l.keepClient,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _changeRelationship(
      item,
      ChangeRelationshipRequestStatus.ended,
      l.relationshipEnded,
    );
  }

  /// [item.id] is the client's user id for ACTIVE and PAUSED rows.
  Future<void> _changeRelationship(
    ClientListItem item,
    ChangeRelationshipRequestStatus status,
    String Function(String name) done,
  ) {
    final l = AppLocalizations.of(context);
    return _runAction(() async {
      await ref
          .read(clientsRepositoryProvider)
          .changeRelationship(item.id, status);
      _snack(done(item.name ?? l.clientsNoName));
    });
  }

  /// Runs a row action, reports a failure, then reloads the list (also after
  /// a failure: the invitation or relationship may have changed meanwhile).
  Future<void> _runAction(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on ApiError catch (e) {
      if (mounted) _snack(errorMessage(AppLocalizations.of(context), e));
    } catch (_) {
      if (mounted) {
        _snack(
          errorMessage(
            AppLocalizations.of(context),
            const ApiError(code: 'UNKNOWN'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _reload();
      }
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final query = widget.query;
    final result = ref.watch(clientListProvider(query));
    final auth = ref.watch(authControllerProvider);
    final verified =
        auth is SignedIn && auth.user.status == UserResponseStatus.active;

    // A page past the end (e.g. after cancelling its last row): show the last.
    final page = result.value;
    final pastEnd = page != null && _isPastEnd(page);
    if (pastEnd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _show(query.withPage(max(0, page.totalPages - 1)));
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < clientCardsBreakpoint;
        final gutter = narrow ? 16.0 : 32.0;
        return ListView(
          padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 32),
          children: [
            _Header(
              total: page?.totalItems,
              verified: verified,
              onAdd: _addClient,
            ),
            const SizedBox(height: 20),
            _Toolbar(
              search: _search,
              status: query.status,
              onSearchChanged: _onSearchChanged,
              onStatusChanged: (s) => _show(query.withStatus(s)),
            ),
            const SizedBox(height: 16),
            if (result.hasError && !result.isLoading)
              _ErrorView(
                message: errorMessage(l, switch (result.error) {
                  final ApiError e => e,
                  _ => const ApiError(code: 'UNKNOWN'),
                }),
                onRetry: _reload,
              )
            else if (page != null)
              // While reloading, the previous rows stay visible.
              _buildPage(context, page, narrow, verified)
            else
              const _Centered(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    ClientListPage page,
    bool narrow,
    bool verified,
  ) {
    final l = AppLocalizations.of(context);
    final query = widget.query;
    if (page.items.isEmpty) {
      if (_isPastEnd(page)) {
        return const _Centered(child: CircularProgressIndicator());
      }
      if (query.hasFilters) {
        return _EmptyState(
          icon: Icons.search_off,
          title: l.clientsNoMatchTitle,
          action: OutlinedButton(
            onPressed: _clearFilters,
            child: Text(l.clientsClearFilters),
          ),
        );
      }
      return _EmptyState(
        icon: Icons.group_add_outlined,
        title: l.clientsEmptyTitle,
        body: l.clientsEmptyBody,
        action: FilledButton(
          onPressed: verified ? _addClient : null,
          child: Text(l.clientsInviteFirst),
        ),
      );
    }

    final actions = _RowActions(
      enabled: !_busy,
      canRegenerate: verified,
      onRegenerate: _regenerate,
      onCancel: _cancel,
      onPause: _pause,
      onResume: _resume,
      onEnd: _end,
    );
    final first = page.page * page.size + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (narrow)
          for (final item in page.items) _ClientCard(item, actions: actions)
        else
          _ClientTable(page.items, actions: actions),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              l.clientsRange(
                first,
                first + page.items.length - 1,
                page.totalItems,
              ),
              style: const TextStyle(color: AppTokens.textSubtle),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: l.previousPage,
              onPressed: page.page > 0
                  ? () => _show(query.withPage(page.page - 1))
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: l.nextPage,
              onPressed: page.page + 1 < page.totalPages
                  ? () => _show(query.withPage(page.page + 1))
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.total,
    required this.verified,
    required this.onAdd,
  });

  final int? total;
  final bool verified;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final total = this.total;
    final button = FilledButton(
      onPressed: verified ? onAdd : null,
      child: Text(l.addClientButton),
    );
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      spacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.clientsTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (total != null) ...[
              const SizedBox(width: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTokens.surface3,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  child: Text(
                    '$total',
                    style: const TextStyle(color: AppTokens.textMuted),
                  ),
                ),
              ),
            ],
          ],
        ),
        verified
            ? button
            : Tooltip(message: l.addClientNeedsVerifiedEmail, child: button),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.search,
    required this.status,
    required this.onSearchChanged,
    required this.onStatusChanged,
  });

  final TextEditingController search;
  final ClientListStatus? status;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ClientListStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: TextField(
            controller: search,
            onChanged: onSearchChanged,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: l.clientsSearchHint,
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              counterText: '',
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<ClientListStatus?>(
            key: ValueKey(status),
            initialValue: status,
            isDense: true,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l.clientsStatusFilter,
              isDense: true,
            ),
            items: [
              DropdownMenuItem(value: null, child: Text(l.clientsStatusAll)),
              for (final s in ClientListStatus.$valuesDefined)
                DropdownMenuItem(
                  value: s,
                  child: Text(clientStatusLabel(l, s)),
                ),
            ],
            onChanged: onStatusChanged,
          ),
        ),
      ],
    );
  }
}

/// The ⋮ menu of a row: invitation actions for INVITED, relationship actions
/// for ACTIVE and PAUSED, nothing for ENDED.
class _RowActions {
  const _RowActions({
    required this.enabled,
    required this.canRegenerate,
    required this.onRegenerate,
    required this.onCancel,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  final bool enabled;
  final bool canRegenerate;
  final ValueChanged<ClientListItem> onRegenerate;
  final ValueChanged<ClientListItem> onCancel;
  final ValueChanged<ClientListItem> onPause;
  final ValueChanged<ClientListItem> onResume;
  final ValueChanged<ClientListItem> onEnd;

  Widget build(BuildContext context, ClientListItem item) {
    final l = AppLocalizations.of(context);
    PopupMenuItem<void> danger(String label, VoidCallback onTap) =>
        PopupMenuItem(
          onTap: onTap,
          child: Text(
            label,
            style: const TextStyle(color: AppTokens.errorText),
          ),
        );
    final (
      String tooltip,
      List<PopupMenuEntry<void>> items,
    ) = switch (item.status) {
      ClientListStatus.invited => (
        l.invitationActions,
        [
          PopupMenuItem(
            enabled: canRegenerate,
            onTap: () => onRegenerate(item),
            child: Text(l.regenerateLink),
          ),
          danger(l.cancelInvitation, () => onCancel(item)),
        ],
      ),
      ClientListStatus.active => (
        l.clientActions,
        [
          PopupMenuItem(onTap: () => onPause(item), child: Text(l.pauseClient)),
          danger(l.endRelationship, () => onEnd(item)),
        ],
      ),
      ClientListStatus.paused => (
        l.clientActions,
        [
          PopupMenuItem(
            onTap: () => onResume(item),
            child: Text(l.resumeClient),
          ),
          danger(l.endRelationship, () => onEnd(item)),
        ],
      ),
      _ => ('', const <PopupMenuEntry<void>>[]),
    };
    if (items.isEmpty) return const SizedBox(width: 40);
    return PopupMenuButton<void>(
      tooltip: tooltip,
      enabled: enabled,
      icon: const Icon(Icons.more_vert, color: AppTokens.textMuted),
      itemBuilder: (_) => items,
    );
  }
}

String _formatDate(BuildContext context, DateTime? value) {
  if (value == null) return '—';
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).format(value.toLocal());
}

/// Status badge plus, for an invitation, when it expires (or that it has).
class _StatusCell extends StatelessWidget {
  const _StatusCell(this.item);

  final ClientListItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final expiresAt = item.invitationExpiresAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClientStatusBadge(item.status),
        if (item.status == ClientListStatus.invited && expiresAt != null) ...[
          const SizedBox(height: 4),
          Text(
            item.invitationExpired
                ? l.clientsInvitationExpired
                : l.clientsInvitationExpires(_formatDate(context, expiresAt)),
            style: TextStyle(
              fontSize: 12,
              color: item.invitationExpired
                  ? AppTokens.errorText
                  : AppTokens.textSubtle,
            ),
          ),
        ],
      ],
    );
  }
}

class _ClientTable extends StatelessWidget {
  const _ClientTable(this.items, {required this.actions});

  final List<ClientListItem> items;
  final _RowActions actions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const header = TextStyle(
      color: AppTokens.textSubtle,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    Widget row(List<Widget> cells, {bool isHeader = false}) => Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isHeader ? 12 : 10,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTokens.border)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: cells[0]),
          Expanded(flex: 3, child: cells[1]),
          Expanded(flex: 2, child: cells[2]),
          Expanded(flex: 2, child: cells[3]),
          SizedBox(width: 40, child: cells.length > 4 ? cells[4] : null),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.surface,
        border: Border.all(color: AppTokens.border),
        borderRadius: BorderRadius.circular(AppTokens.radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radius),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: row([
                Text(l.clientsColumnName.toUpperCase(), style: header),
                Text(l.clientsColumnEmail.toUpperCase(), style: header),
                Text(l.clientsColumnStatus.toUpperCase(), style: header),
                Text(l.clientsColumnInvited.toUpperCase(), style: header),
              ], isHeader: true),
            ),
            for (final item in items)
              row([
                _NameCell(item),
                Text(
                  item.email ?? '—',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTokens.textMuted),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusCell(item),
                ),
                Text(
                  _formatDate(context, item.invitedAt),
                  style: const TextStyle(color: AppTokens.textMuted),
                ),
                actions.build(context, item),
              ]),
          ],
        ),
      ),
    );
  }
}

class _NameCell extends StatelessWidget {
  const _NameCell(this.item);

  final ClientListItem item;

  @override
  Widget build(BuildContext context) {
    final name = item.name ?? AppLocalizations.of(context).clientsNoName;
    final initials = name
        .split(RegExp(r'[\s-]+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p.characters.first.toUpperCase())
        .join();
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppTokens.surface3,
          child: Text(
            initials,
            style: const TextStyle(
              color: AppTokens.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard(this.item, {required this.actions});

  final ClientListItem item;
  final _RowActions actions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        border: Border.all(color: AppTokens.border),
        borderRadius: BorderRadius.circular(AppTokens.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NameCell(item),
                const SizedBox(height: 6),
                Text(
                  item.email ?? '—',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTokens.textMuted),
                ),
                const SizedBox(height: 8),
                _StatusCell(item),
                const SizedBox(height: 6),
                Text(
                  '${l.clientsColumnInvited}: ${_formatDate(context, item.invitedAt)}',
                  style: const TextStyle(
                    color: AppTokens.textSubtle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions.build(context, item),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    this.body,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = this.body;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        border: Border.all(color: AppTokens.border),
        borderRadius: BorderRadius.circular(AppTokens.radius),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTokens.textSubtle),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTokens.textMuted),
              ),
            ),
          ],
          const SizedBox(height: 20),
          action,
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _EmptyState(
      icon: Icons.cloud_off_outlined,
      title: l.clientsLoadError,
      body: message,
      action: OutlinedButton(onPressed: onRetry, child: Text(l.retry)),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Center(child: child),
  );
}
