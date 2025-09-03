import 'package:camera/camera.dart';
import 'package:camera_stream/core/routing/routes.dart';
import 'package:camera_stream/feature/authentication/presentation/views/sign_in_view.dart'
    show SignInView;
import 'package:camera_stream/feature/home/presentation/ui/camera_screen.dart';
import 'package:go_router/go_router.dart';

import '../../feature/authentication/presentation/views/sign_up_view.dart';
import '../../feature/startup/presentation/on_boarding_view.dart';
import '../../feature/startup/presentation/splash_screen.dart';
import '../../feature/switcher/presentation/streaming_view.dart';
import '../../feature/switcher/presentation/switcher_view.dart';
import '../widgets/custom_slider_transition.dart';

abstract class AppRouters {
  static final GoRouter goRouter = GoRouter(
    routes: [
      GoRoute(
        path: Routes.splash,
        pageBuilder: (context, state) => CustomSliderTransition(
          key: state.pageKey,
          child: const SplashScreen(),
          duration: 700,
        ),
      ),
      GoRoute(
        path: Routes.onBoarding,
        pageBuilder: (context, state) => CustomSliderTransition(
          key: state.pageKey,
          child: const Onboarding(),
          duration: 300,
        ),
      ),
      GoRoute(
        path: Routes.streaming,
        builder: (context, state) => const StreamingView(),
      ),
      GoRoute(
        path: Routes.camera,
        pageBuilder: (context, state) => CustomSliderTransition(
          key: state.pageKey,
          child: CameraScreen(cameras: state.extra as List<CameraDescription>),
          duration: 300,
        ),
      ),
      GoRoute(
        path: Routes.signIn,
        pageBuilder: (context, state) => CustomSliderTransition(
          key: state.pageKey,
          child: const SignInView(),
          duration: 300,
        ),
      ),
      GoRoute(
        path: Routes.signUp,
        pageBuilder: (context, state) => CustomSliderTransition(
          key: state.pageKey,
          child: const SignUpView(),
          duration: 300,
        ),
      ),
      GoRoute(
        path: Routes.switchView,
        builder: (context, state) => const SwitcherView(),
      ),
    ],
  );
}
