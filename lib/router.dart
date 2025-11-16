import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/main.dart';

// GoRouter 설정
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      // 향후 추가될 경로들 (예: 모임 상세 페이지)
      // routes: <RouteBase>[
      //   GoRoute(
      //     path: 'club/:clubId',
      //     builder: (BuildContext context, GoRouterState state) {
      //       final String clubId = state.pathParameters['clubId']!;
      //       return ClubDetailsScreen(clubId: clubId);
      //     },
      //   ),
      // ],
    ),
  ],
);
