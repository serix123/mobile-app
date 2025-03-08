import 'package:flutter/material.dart';


import 'package:online_reservation/main.dart';
import 'package:provider/provider.dart';

class RouteGenerator {
  static const homeScreen = MyHomePage.screenId;


  static Route<dynamic> generateRoute(RouteSettings settings, BuildContext context) {
    final args = settings.arguments;
    switch (settings.name) {
      case homeScreen:
        return MaterialPageRoute(builder: (_) => const MyHomePage());
      // case loginScreen:
      //   return MaterialPageRoute(builder: (_) => const LoginScreen());
      default:
        return MaterialPageRoute(builder: (_) => const MyHomePage());

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
