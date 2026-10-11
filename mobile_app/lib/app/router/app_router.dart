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
import '../../features/plants/views/plant_list_page.dart';
import '../../features/guide/presentation/pages/tool_detail_page.dart';
import '../../features/guide/presentation/pages/disease_detail_page.dart';
import '../../features/guide/data/guide_data.dart';
import '../../features/detection/presentation/pages/data_inspection_page.dart';
import '../../features/detection/presentation/pages/photo_source_page.dart';
import '../../features/detection/presentation/pages/photo_preview_page.dart';
import '../../features/detection/presentation/pages/detection_result_page.dart';
import '../../features/history/data/history_data.dart';
import '../../features/history/views/history_page.dart';
import '../../features/history/views/history_detail_page.dart';
import '../../features/history/views/treatment_recommendation_page.dart';
import '../../features/history/views/disease_detail_page.dart';
import '../../features/sync/views/sync_status_page.dart';
import '../../features/sync/views/sync_process_page.dart';
import '../../features/sync/views/sync_result_page.dart';

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
        path: '/plants',
        name: 'plants',
        builder: (context, state) => const PlantListPage(),
      ),
      GoRoute(
        path: '/tool-detail',
        name: 'tool-detail',
        builder: (context, state) {
          final tool = state.extra as ToolModel;
          return ToolDetailPage(tool: tool);
        },
      ),
      GoRoute(
        path: '/disease-detail',
        name: 'disease-detail',
        builder: (context, state) {
          final disease = state.extra as DiseaseModel;
          return DiseaseDetailPage(disease: disease);
        },
      ),
      GoRoute(
        path: '/data-inspection',
        name: 'data-inspection',
        builder: (context, state) {
          final plant = state.extra;
          return DataInspectionPage(
            plant: plant is InspectionPlant
                ? plant
                : const InspectionPlant(
                    name: 'Tomat Pot Depan',
                    id: 'TMT-001',
                    location: 'Teras depan',
                  ),
          );
        },
      ),
      GoRoute(
        path: '/photo-source',
        name: 'photo-source',
        builder: (context, state) {
          final draft = state.extra;
          return PhotoSourcePage(
            draft: draft is InspectionDraft
                ? draft
                : InspectionDraft(
                    plant: const InspectionPlant(
                      name: 'Tomat Pot Depan',
                      id: 'TMT-001',
                      location: 'Teras depan',
                    ),
                    inspectionDate: DateTime.now(),
                    note: '',
                  ),
          );
        },
      ),
      GoRoute(
        path: '/photo-preview',
        name: 'photo-preview',
        builder: (context, state) {
          final selection = state.extra;
          return PhotoPreviewPage(
            selection: selection is InspectionPhotoSelection
                ? selection
                : InspectionPhotoSelection(
                    draft: InspectionDraft(
                      plant: const InspectionPlant(
                        name: 'Tomat Pot Depan',
                        id: 'TMT-001',
                        location: 'Teras depan',
                      ),
                      inspectionDate: DateTime.now(),
                      note: '',
                    ),
                    source: 'Galeri',
                  ),
          );
        },
      ),
      GoRoute(
        path: '/detection-result',
        name: 'detection-result',
        builder: (context, state) {
          final selection = state.extra;
          return DetectionResultPage(
            selection: selection is InspectionPhotoSelection
                ? selection
                : InspectionPhotoSelection(
                    draft: InspectionDraft(
                      plant: const InspectionPlant(
                        name: 'Tomat Pot Depan',
                        id: 'TMT-001',
                        location: 'Teras depan',
                      ),
                      inspectionDate: DateTime.now(),
                      note: '',
                    ),
                    source: 'Galeri',
                  ),
          );
        },
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) {
          final plant = state.extra;
          return HistoryPage(plant: plant is HistoryPlant ? plant : null);
        },
      ),
      GoRoute(
        path: '/history-detail',
        name: 'history-detail',
        builder: (context, state) {
          final record = state.extra;
          return HistoryDetailPage(
            record: record is HistoryRecord ? record : HistoryData.records.first,
          );
        },
      ),
      GoRoute(
        path: '/treatment-recommendation',
        name: 'treatment-recommendation',
        builder: (context, state) {
          final record = state.extra;
          return TreatmentRecommendationPage(
            record: record is HistoryRecord ? record : HistoryData.records.first,
          );
        },
      ),
      GoRoute(
        path: '/history-disease-detail',
        name: 'history-disease-detail',
        builder: (context, state) {
          final record = state.extra;
          return HistoryDiseaseDetailPage(
            record: record is HistoryRecord ? record : HistoryData.records.first,
          );
        },
      ),
      GoRoute(
        path: '/sync-status',
        name: 'sync-status',
        builder: (context, state) => const SyncStatusPage(),
      ),
      GoRoute(
        path: '/sync-process',
        name: 'sync-process',
        builder: (context, state) {
          final failure = state.extra;
          return SyncProcessPage(isFailure: failure is bool && failure);
        },
      ),
      GoRoute(
        path: '/sync-result',
        name: 'sync-result',
        builder: (context, state) {
          final failure = state.extra;
          return SyncResultPage(isFailure: failure is bool && failure);
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
