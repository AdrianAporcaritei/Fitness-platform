import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/language_switch.dart';
import '../../../core/widgets/pending_email_banner.dart';

/// Below this width the sidebar moves into a drawer.
const coachSidebarBreakpoint = 840.0;

/// Layout of every coach page: sidebar navigation (only Clients works for
/// now; the other sections are shown disabled), the email-confirmation
/// banner for an unverified coach, and [child].
class CoachShell extends ConsumerWidget {
  const CoachShell({super.key, required this.location, required this.child});

  /// The current path, used to highlight the active section.
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth is SignedIn ? auth.user : null;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (user?.status == UserResponseStatus.pending)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: PendingEmailBanner(email: user!.email),
          ),
        Expanded(child: child),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= coachSidebarBreakpoint) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 240,
                  child: _Sidebar(location: location, user: user),
                ),
                const VerticalDivider(width: 1, color: AppTokens.border),
                Expanded(child: SafeArea(left: false, child: content)),
              ],
            ),
          );
        }
        final l = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppTokens.surface,
            surfaceTintColor: Colors.transparent,
            title: const AppLogo(size: 28),
            leading: Builder(
              builder: (context) => IconButton(
                tooltip: l.openMenu,
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: Drawer(
            backgroundColor: AppTokens.surface,
            child: _Sidebar(location: location, user: user, inDrawer: true),
          ),
          body: SafeArea(top: false, child: content),
        );
      },
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.location,
    required this.user,
    this.inDrawer = false,
  });

  final String location;
  final UserResponse? user;
  final bool inDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = this.user;

    void go(String path) {
      if (inDrawer) Navigator.of(context).pop();
      context.go(path);
    }

    return ColoredBox(
      color: AppTokens.surface,
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppLogo(size: 32),
                ),
              ),
              const SizedBox(height: 24),
              _NavItem(
                icon: Icons.space_dashboard_outlined,
                label: l.navDashboard,
              ),
              _NavItem(
                icon: Icons.people_outline,
                label: l.navClients,
                selected: location.startsWith(Routes.coachClients),
                onTap: () => go(Routes.coachClients),
              ),
              _NavItem(icon: Icons.fitness_center, label: l.navWorkouts),
              _NavItem(icon: Icons.restaurant_menu, label: l.navMealPlans),
              _NavItem(icon: Icons.chat_bubble_outline, label: l.navChat),
              const Spacer(),
              if (user != null) _UserBlock(user: user),
              const SizedBox(height: 8),
              Row(
                children: [
                  const LanguageSwitch(),
                  const Spacer(),
                  IconButton(
                    tooltip: l.signOut,
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).logout(),
                    color: AppTokens.textMuted,
                    icon: const Icon(Icons.logout, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A sidebar entry; without [onTap] it is disabled and marked "coming soon".
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final enabled = onTap != null;
    final color = selected
        ? AppTokens.text
        : enabled
        ? AppTokens.textMuted
        : AppTokens.textSubtle.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? AppTokens.surface3 : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AppTokens.accent : color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (!enabled)
                  Text(
                    l.navComingSoon,
                    style: const TextStyle(
                      color: AppTokens.textSubtle,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserBlock extends StatelessWidget {
  const _UserBlock({required this.user});

  final UserResponse user;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final initials = [user.firstName, user.lastName]
        .where((s) => s.isNotEmpty)
        .map((s) => s.characters.first.toUpperCase())
        .join();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTokens.surface3,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppTokens.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  l.roleCoach,
                  style: const TextStyle(
                    color: AppTokens.textSubtle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
