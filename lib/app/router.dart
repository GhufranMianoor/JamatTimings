import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/core/providers/supabase_provider.dart';
import 'package:jamat_timings/features/home/home_screen.dart';
import 'package:jamat_timings/features/home/guest_shell.dart';
import 'package:jamat_timings/features/map/map_screen.dart';
import 'package:jamat_timings/features/search/search_screen.dart';
import 'package:jamat_timings/features/favourites/favourites_screen.dart';
import 'package:jamat_timings/features/masjid_detail/masjid_detail_screen.dart';
import 'package:jamat_timings/features/settings/settings_screen.dart';
import 'package:jamat_timings/features/auth/login_screen.dart';
import 'package:jamat_timings/features/auth/forgot_password_screen.dart';
import 'package:jamat_timings/features/admin_dashboard/admin_dashboard_screen.dart';
import 'package:jamat_timings/features/admin_dashboard/admin_shell.dart';
import 'package:jamat_timings/features/timing_editor/timing_editor_screen.dart';
import 'package:jamat_timings/features/masjid_request/masjid_request_screen.dart';
import 'package:jamat_timings/features/super_admin/super_admin_shell.dart';
import 'package:jamat_timings/features/super_admin/approval_queue/approval_queue_screen.dart';
import 'package:jamat_timings/features/super_admin/masjid_management/masjid_management_screen.dart';
import 'package:jamat_timings/features/super_admin/admin_management/admin_management_screen.dart';
import 'package:jamat_timings/features/super_admin/audit_logs/audit_log_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final loggingIn = state.matchedLocation.startsWith('/auth');
      final isAdminArea = state.matchedLocation.startsWith('/admin') || 
                          state.matchedLocation.startsWith('/super-admin');

      if (isAdminArea && user == null) {
        return '/auth/login';
      }

      if (loggingIn && user != null) {
        return '/admin/dashboard';
      }

      return null;
    },
    routes: [
      // Guest Bottom Navigation Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return GuestShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favourites',
                builder: (context, state) => const FavouritesScreen(),
              ),
            ],
          ),
        ],
      ),

      // Masjid Details Route
      GoRoute(
        path: '/masjid/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MasjidDetailScreen(masjidId: id);
        },
      ),

      // Settings Route
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/auth/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Masjid Admin Stateful Navigation Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/dashboard',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/request',
                builder: (context, state) => const MasjidRequestScreen(),
              ),
            ],
          ),
        ],
      ),

      // Edit timings screen
      GoRoute(
        path: '/admin/timings/:masjidId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final masjidId = state.pathParameters['masjidId']!;
          return TimingEditorScreen(masjidId: masjidId);
        },
      ),

      // Super Admin Stateful Navigation Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SuperAdminShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/super-admin/queue',
                builder: (context, state) => const ApprovalQueueScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/super-admin/masjids',
                builder: (context, state) => const MasjidManagementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/super-admin/admins',
                builder: (context, state) => const AdminManagementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/super-admin/audit',
                builder: (context, state) => const AuditLogScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
