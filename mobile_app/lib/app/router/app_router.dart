import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/personal_information_page.dart';
import '../../features/profile/presentation/pages/help_faq_page.dart';
import '../../features/profile/presentation/pages/about_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/guide/presentation/pages/guide_list_page.dart';
import '../../features/guide/presentation/pages/guide_detail_page.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/guides',
        name: 'guides',
        builder: (context, state) => const GuideListPage(),
      ),
      GoRoute(
        path: '/guide-detail',
        name: 'guide-detail',
        builder: (context, state) {
          final tabIndex = (state.extra as int?) ?? 0;
          return GuideDetailPage(initialTabIndex: tabIndex);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/personal-information',
        name: 'personal-information',
        builder: (context, state) {
          return const PersonalInformationPage();
        },
      ),
      GoRoute(
        path: '/help-faq',
        name: 'help-faq',
        builder: (context, state) => const HelpFaqPage(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
}