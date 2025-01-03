import 'package:go_router/go_router.dart';
import 'package:notifications/presentation/screens/screens.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/', 
      builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
      path: '/push_details/:messageId', 
      builder: (context, state) => DetailScreens(pushMessageId: state.pathParameters['messageId'] ?? ''),
      ),

  ]
);