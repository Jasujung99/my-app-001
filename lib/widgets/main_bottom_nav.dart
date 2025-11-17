// lib/widgets/main_bottom_nav.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/theme/app_theme.dart';

enum MainTab { home, review, honor }

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key, required this.current});

  final MainTab current;

  @override
  Widget build(BuildContext context) {
    Color itemColor(MainTab tab) => current == tab ? AppColors.midnight : AppColors.accent;

    void go(MainTab tab) {
      switch (tab) {
        case MainTab.home:
          context.go('/');
          break;
        case MainTab.review:
          context.go('/review');
          break;
        case MainTab.honor:
          context.go('/honor');
          break;
      }
    }

    Widget buildItem({required MainTab tab, required IconData icon, required String label}) {
      final selected = current == tab;
      return Expanded(
        child: InkWell(
          onTap: () => go(tab),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: itemColor(tab)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: itemColor(tab),
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, -8),
                )
              ],
            ),
            child: Row(
              children: [
                buildItem(tab: MainTab.home, icon: Icons.home_outlined, label: 'Home'),
                buildItem(tab: MainTab.review, icon: Icons.reviews_outlined, label: 'Review'),
                buildItem(tab: MainTab.honor, icon: Icons.emoji_events_outlined, label: 'Honor'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
