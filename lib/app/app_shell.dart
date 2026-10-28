import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/clay_surface.dart';
import 'theme/clay_tokens.dart';

/// Tab scaffold with a floating clay navigation bar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _tabs = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.menu_book_rounded, Icons.menu_book_outlined, 'Learn'),
    (Icons.favorite_rounded, Icons.favorite_border_rounded, 'My Health'),
    (Icons.insights_rounded, Icons.insights_outlined, 'Progress'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.md),
        child: ClaySurface(
          radius: 28,
          depth: 1.3,
          padding: const EdgeInsets.symmetric(horizontal: Gap.xs, vertical: Gap.sm),
          child: Row(
            children: [
              for (final (i, (active, inactive, label)) in _tabs.indexed)
                Expanded(
                  child: _NavItem(
                    icon: shell.currentIndex == i ? active : inactive,
                    label: label,
                    selected: shell.currentIndex == i,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      shell.goBranch(i, initialLocation: i == shell.currentIndex);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final color = selected ? clay.accent : clay.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label tab',
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? clay.tone(ClayTone.teal).fill : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  child: Text(
                    label,
                    maxLines: 1,
                    style: context.text.labelSmall!.copyWith(color: color, letterSpacing: 0),
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
