// lib/screens/review_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/main_bottom_nav.dart';
import 'package:myapp/widgets/interactive_card.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final mockReviews = [
      {
        'title': '카뮈 이방인',
        'snippet': '부조리에 맞서는 무감각, 그게 진실일까?',
        'rating': 4.7,
        'author': '김○○'
      },
      {
        'title': '1984',
        'snippet': '감시가 익숙해질 때, 인간성은 어디에 남는가.',
        'rating': 4.9,
        'author': '박○○'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.go('/'),
        ),
        title: Text('Review', style: textTheme.titleMedium),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.paper, AppColors.stardust],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mockReviews.length,
          itemBuilder: (context, index) {
            final item = mockReviews[index];
            final title = item['title'] as String;
            final snippet = item['snippet'] as String;
            final author = item['author'] as String;
            final rating = (item['rating'] as num).toString();
            return InteractiveCard(
              margin: const EdgeInsets.only(bottom: 12),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: textTheme.titleMedium)),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(rating, style: textTheme.bodyMedium),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(snippet, style: textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text('by $author', style: textTheme.bodySmall),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const MainBottomNav(current: MainTab.review),
    );
  }
}
