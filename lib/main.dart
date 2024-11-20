import 'package:eventmanagement/Screen/change_history_page.dart';
import 'package:eventmanagement/Screen/dashboard_department.dart';
import 'package:eventmanagement/Screen/dashboard_student.dart';
import 'package:eventmanagement/Screen/event_list.dart';
import 'package:eventmanagement/Screen/event_management_department.dart';
import 'package:eventmanagement/Screen/feed_back_page.dart';
import 'package:eventmanagement/Screen/login.dart';
import 'package:eventmanagement/Screen/dash_board_entire.dart';
import 'package:eventmanagement/Screen/event_management_entire.dart';
import 'package:eventmanagement/Screen/participant_list.dart';
import 'package:eventmanagement/Screen/profile_personal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: 'Quản lý sự kiện',
            theme: ThemeData(
              scaffoldBackgroundColor: Color(0xFF2E3034),
            ),
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          final bool loggedIn = snapshot.data == true;
          return FutureBuilder(
            future: _getInitialLocation(),
            builder: (context, locationSnapshot) {
              if (locationSnapshot.connectionState == ConnectionState.waiting) {
                return MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else {
                final String initialLocation = loggedIn ? locationSnapshot.data as String : '/login';
                final GoRouter router = GoRouter(
                  routerNeglect: true,
                  initialLocation: initialLocation,
                  routes: [
                    GoRoute(
                      path: '/',
                      builder: (context, state) => const LoginScreen(),
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: const LoginScreen(),
                        name: 'Login',
                      ),
                    ),
                    GoRoute(
                      path: '/login',
                      builder: (context, state) => const LoginScreen(),
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: const LoginScreen(),
                        name: 'Login',
                      ),
                    ),
                    GoRoute(
                      path: '/dashboard_student',
                      builder: (context, state) => const StudentDashboard(),
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: const StudentDashboard(),
                        name: 'Dashboard Student',
                      ),
                    ),
                    GoRoute(
                      path: '/dashboard',
                      builder: (context, state) => const DashboardScreen(),
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: const DashboardScreen(),
                        name: 'Dashboard',
                      ),
                    ),
                    GoRoute(
                      path: '/dashboard_department',
                      builder: (context, state) => const DashboardDepartmentScreen(),
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: const DashboardDepartmentScreen(),
                        name: 'Dashboard Department',
                      ),
                    ),
                    GoRoute(
                      path: '/event-management',
                      builder: (context, state) => const EventManagementScreen(),
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: const EventManagementScreen(),
                        name: 'Event Management',
                      ),
                    ),
                    GoRoute(
                      path: '/participant_list/:eventId/:eventName/:dateEnd',
                      builder: (context, state) {
                        final eventId = state.pathParameters['eventId']!;
                        final eventName = state.pathParameters['eventName']!;
                        final dateEnd = DateTime.parse(state.pathParameters['dateEnd']!);
                        return ParticipantListScreen(eventId: eventId, eventName: eventName, dateEnd: dateEnd);
                      },
                      pageBuilder: (context, state) {
                        final eventId = state.pathParameters['eventId']!;
                        final eventName = state.pathParameters['eventName']!;
                        final dateEnd = DateTime.parse(state.pathParameters['dateEnd']!);
                        return MaterialPage(
                          key: state.pageKey,
                          child: ParticipantListScreen(eventId: eventId, eventName: eventName, dateEnd: dateEnd),
                          name: 'Participant Event',
                        );
                      },
                    ),
                    GoRoute(
                      path: '/event_department_management',
                      builder: (context, state) => const EventDepartmentManagementScreen(),
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: const EventDepartmentManagementScreen(),
                        name: 'Event Department Management',
                      ),
                    ),
                    GoRoute(
                      path: '/profile',
                      builder: (context, state) => const ChangePasswordScreen(),
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: const ChangePasswordScreen(),
                        name: 'Profile',
                      ),
                    ),
                    GoRoute(
                      path: '/list_event',
                      builder: (context, state) => const ListEvent(),
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: const ListEvent(),
                        name: 'Sự kiện',
                      ),
                    ),
                    GoRoute(
                      path: '/feedback/:eventId/:eventName/:dateEnd',
                      builder: (context, state) {
                        final eventId = state.pathParameters['eventId']!;
                        final eventName = state.pathParameters['eventName']!;
                        final dateEnd = DateTime.parse(state.pathParameters['dateEnd']!);
                        return FeedbackListScreen(eventId: eventId, eventName: eventName, dateEnd: dateEnd);
                      },
                      pageBuilder: (context, state) {
                        final eventId = state.pathParameters['eventId']!;
                        final eventName = state.pathParameters['eventName']!;
                        final dateEnd = DateTime.parse(state.pathParameters['dateEnd']!);
                        return MaterialPage(
                          key: state.pageKey,
                          child: FeedbackListScreen(eventId: eventId, eventName: eventName, dateEnd: dateEnd),
                          name: 'Feedback',
                        );
                      },
                    ),
                    GoRoute(
                      path: '/historyChange/:eventId/:eventName/:dateEnd',
                      builder: (context, state) {
                        final eventId = state.pathParameters['eventId']!;
                        final eventName = state.pathParameters['eventName']!;
                        final dateEnd = DateTime.parse(state.pathParameters['dateEnd']!);
                        return ChangeStoreHistoryScreen(eventId: eventId, eventName: eventName, dateEnd: dateEnd);
                      },
                      pageBuilder: (context, state) {
                        final eventId = state.pathParameters['eventId']!;
                        final eventName = state.pathParameters['eventName']!;
                        final dateEnd = DateTime.parse(state.pathParameters['dateEnd']!);
                        return MaterialPage(
                          key: state.pageKey,
                          child: ChangeStoreHistoryScreen(eventId: eventId, eventName: eventName, dateEnd: dateEnd),
                          name: 'Lịch sử thay đổi',
                        );
                      },
                    ),
                    GoRoute(
                      path: '/participant-event/participant-lis/:dateEnd',
                      builder: (context, state) {
                        final args = state.extra as Map<String, dynamic>;
                        return ParticipantListScreen(
                          eventId: args['eventId'],
                          eventName: args['eventName'],
                          dateEnd: args['dateEnd'],
                        );
                      },
                      pageBuilder: (context, state) {
                        final args = state.extra as Map<String, dynamic>;
                        return MaterialPage(
                          key: state.pageKey,
                          child: ParticipantListScreen(
                            eventId: args['eventId'],
                            eventName: args['eventName'],
                            dateEnd: args['dateEnd'],
                          ),
                          name: 'Participant List',
                        );
                      },
                    ),
                  ],
                  redirect: (context, state) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('token');
                    final role = prefs.getString('role');
                    final departmentId = prefs.getString('departmentId');
                    final loggedIn = token != null;
                    final loggingIn = state.uri.toString() == '/login';

                    if (!loggedIn && !loggingIn) return '/login';
                    if (loggedIn && loggingIn) {
                      if (role != null && departmentId != null) {
                        if (role.contains('ADMIN_ENTIRE') && departmentId.contains("EN")) {
                          return '/dashboard';
                        } else if (role.contains('ADMIN_DEPARTMENT')) {
                          return '/dashboard_department';
                        } else if(role.contains('USER')) {
                          return '/dashboard_student';
                        }
                      }
                      return '/login';
                    }
                    return null;
                  },
                );

                return MaterialApp.router(
                  title: 'Quản lý sự kiện',
                  theme: ThemeData(
                    popupMenuTheme: const PopupMenuThemeData(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                    useMaterial3: true,
                  ),
                  routerConfig: router,
                );
              }
            },
          );
        }
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  Future<String> _getInitialLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final departmentId = prefs.getString('departmentId');

    if (role != null && departmentId != null) {
      if (role.contains('ADMIN_ENTIRE') && departmentId.contains("EN")) {
        return '/login';
      } else if (role.contains('ADMIN_DEPARTMENT')) {
        return '/dashboard_department';
      } else if(role.contains('USER')) {
        return '/list_event';
      }
    }
    return '/login';
  }
}