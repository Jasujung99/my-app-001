// lib/router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/create_br_screen.dart';
import 'package:myapp/screens/br_detail_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/create_meeting_screen.dart';
import 'package:myapp/screens/meeting_detail_screen.dart'; // 새로 추가
import 'package:myapp/screens/review_screen.dart';
import 'package:myapp/screens/honor_screen.dart';
import 'package:myapp/services/auth_service.dart';

class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  late final GoRouter router = GoRouter(
    refreshListenable: authService,
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return HomeScreen();
        },
      ),
      GoRoute(
        path: '/create-br',
        builder: (BuildContext context, GoRouterState state) {
          return CreateBRScreen();
        },
      ),
      GoRoute(
        path: '/create-meeting',
        builder: (BuildContext context, GoRouterState state) {
          return CreateMeetingScreen();
        },
      ),
      GoRoute(
        path: '/br/:brId',
        builder: (BuildContext context, GoRouterState state) {
          final brId = state.pathParameters['brId']!;
          return BRDetailScreen(brId: brId);
        },
      ),
      GoRoute(
        path: '/meetings/:meetingId',
        builder: (BuildContext context, GoRouterState state) {
          final meetingId = state.pathParameters['meetingId']!;
          return MeetingDetailScreen(meetingId: meetingId);
        },
      ),
      GoRoute(
        path: '/review',
        builder: (BuildContext context, GoRouterState state) {
          return const ReviewScreen();
        },
      ),
      GoRoute(
        path: '/honor',
        builder: (BuildContext context, GoRouterState state) {
          return const HonorScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (BuildContext context, GoRouterState state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authService.isLoggedIn;
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) {
        return '/login';
      }

      if (loggedIn && loggingIn) {
        return '/';
      }

      return null;
    },
  );
}
