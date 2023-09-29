import 'package:flutter/material.dart';
import 'package:travel_planner/app/presentation/authentication/sign_up/sign_up.dart';
import 'package:travel_planner/app/presentation/chat/screen/chat_screen.dart';
import 'package:travel_planner/app/presentation/home_page/home_page.dart';
import 'package:travel_planner/app/presentation/splash/splash_screen.dart';
import 'package:travel_planner/data/model/conversation.dart';

class AppRouter {
  /// A custom screen navigation handler that handles the animation of moving from one screen to another
  /// The current setting sets up the app to mimic the navigation on IOS devices on every of our app variant
  ///
  static _getPageRoute(
    Widget child, [
    String? routeName,
    dynamic args,
  ]) =>
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        settings: RouteSettings(
          name: routeName,
          arguments: args,
        ),
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );

  /// This is used to generate routes and manage routes in our flutter app.
  /// This supports stacking and persistence as we are using the named method.
  /// Therefore for we to stack pages on each other every page has to handle it's own data and state
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return _getPageRoute(const SplashScreen());
      case SignUpScreen.routeName:
        return _getPageRoute(const SignUpScreen());
      case HomePage.routeName:
        return _getPageRoute(const HomePage());
      case ChatScreen.routeName:
        final s = settings.arguments as ObjConversation;
        return _getPageRoute(ChatScreen(
          conversation: s,
        ));

      default:
        return _getPageRoute(const SplashScreen());
    }
  }
}
