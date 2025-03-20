import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:online_reservation/Features/Authentication/Presentation/login.view.dart';
import 'package:online_reservation/Features/Authentication/Presentation/register.view.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.list.view.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.view.dart';
import 'package:online_reservation/Features/Visitor/list.view.dart';
import 'package:online_reservation/main.dart';
import 'package:provider/provider.dart';

class RouteGenerator {
  // static const homeScreen = MyHomePage.screenId;
  static const loginScreen = LoginScreen.screenId;
  static const registerScreen = RegistrationScreen.screenId;
  static const visitorFormScreen = VisitorFormScreen.screenId;
  static const visitorListScreen = VisitsListScreen.screenId;

  static Route<dynamic> generateRoute(RouteSettings settings, bool isLoggedIn, BuildContext context) {
    final args = settings.arguments;

    if (isLoggedIn) {
      switch (settings.name) {
        case visitorFormScreen:
          if (args is VisitorScreenConfig) {
            return MaterialPageRoute(
              builder: (_) => VisitorFormScreen(
                mode: args.mode,
                onSubmit: args.onSubmit,
                initialData: args.initialData,
                onDelete: args.onDelete,
              ),
            );
          } else {
            return MaterialPageRoute(
              builder: (_) => VisitorFormScreen(
                mode: FormMode.create,
                onSubmit: (item) {},
                onDelete: () {},
              ),
            );
          }
        case visitorListScreen:
          return MaterialPageRoute(builder: (_) => const VisitsListScreen());
        default:
          return MaterialPageRoute(builder: (_) => const LoginScreen());
      }
    } else {
      switch (settings.name) {
        case loginScreen:
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        case registerScreen:
          return MaterialPageRoute(builder: (_) => const RegistrationScreen());
        default:
          return MaterialPageRoute(builder: (_) => const LoginScreen());
      }
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
