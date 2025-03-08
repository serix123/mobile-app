import 'package:flutter/material.dart';
import 'package:online_reservation/Presentation/Modules/Authentication/login.view.dart';


import 'package:online_reservation/main.dart';
import 'package:provider/provider.dart';

class RouteGenerator {
  static const homeScreen = MyHomePage.screenId;
  static const loginScreen = LoginScreen.screenId;


  static Route<dynamic> generateRoute(RouteSettings settings, BuildContext context) {
    final args = settings.arguments;
    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case homeScreen:
        return MaterialPageRoute(builder: (_) => const MyHomePage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Page not found!")),
      );
    });
  }
}
