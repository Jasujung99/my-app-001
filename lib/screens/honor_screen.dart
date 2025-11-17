// lib/screens/honor_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/main_bottom_nav.dart';
import 'package:myapp/widgets/interactive_card.dart';

class HonorScreen extends StatelessWidget {
  const HonorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final members = [
      {'rank': 1, 'name': '김○○', 'count': 12},
      {'rank': 2, 'name': '이○○', 'count': 10},
      {'rank': 3, 'name': '박○○', 'count': 9},
      {'rank': 4, 'name': '최○○', 'count': 8},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.go('/'),
        ),
        title: Text('Honor', style: textTheme.titleMedium),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.paper, AppColors.stardust],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('명예 회원', style: textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('꾸준히 토론에 참여해 준 멤버들입니다.', style: textTheme.bodySmall),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return InteractiveCard(
                      borderRadius: 18,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.midnight.withOpacity(0.1),
                              child: Text(
                                '${member['rank']}위',
                                style: textTheme.labelLarge?.copyWith(color: AppColors.midnight),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(member['name']!.toString(), style: textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text('참여 ${member['count']}회', style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNav(current: MainTab.honor),
    );
  }
}
