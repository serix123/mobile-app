import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/FormFieldMode.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:online_reservation/Features/Authentication/Presentation/login.view.dart';
import 'package:online_reservation/Features/Authentication/Presentation/register.view.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.list.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.view.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/Features/Events/Presentation/event.form.dart';
import 'package:online_reservation/Features/Events/Presentation/event.list.dart';
import 'package:online_reservation/Features/Events/Presentation/event.view.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.list.view.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.view.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:online_reservation/Features/Profile/Presentation/profile.view.dart';
import 'package:online_reservation/Features/Resident/Presentation/residence.list.dart';
import 'package:online_reservation/Features/Resident/Presentation/residence.view.dart';
import 'package:online_reservation/Features/Users/Presentation/user.list.view.dart';
import 'package:online_reservation/Features/Users/Presentation/user.view.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.list.view.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.view.dart';
import 'package:provider/provider.dart';

class RouteGenerator {
  static const visitorFormScreen = VisitorFormScreen.screenId;
  static const visitorListScreen = VisitsListScreen.screenId;
  static const resourceListScreen = ResourceListScreen.screenId;
  static const resourceFormScreen = ResourceFormScreen.screenId;

  static const homeScreen = "/Home";
  static const loginScreen = LoginScreen.screenId;
  static const registerScreen = RegistrationScreen.screenId;
  static const issueFormScreen = IssueFormScreen.screenId;
  static const issuesListScreen = IssuesListScreen.screenId;
  static const profileScreen = ProfileScreen.screenId;
  static const residentListScreen = ResidentListScreen.screenId;
  static const residenceFormScreen = ResidenceFormScreen.screenId;
  static const userListScreen = UserListScreen.screenId;
  static const userScreen = UserScreen.screenId;
  static const eventListScreen = EventListScreen.screenId;
  static const eventViewScreen = EventViewScreen.screenId;
  static const eventEditScreen = EventEditScreen.screenId;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case homeScreen:
        return MaterialPageRoute(builder: (ctx) {
          final isLoggedIn = ctx.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) return const LoginScreen();
          return const IssuesListScreen();
        });
      case issuesListScreen:
        return MaterialPageRoute(builder: (_) => const IssuesListScreen());
      case issueFormScreen:
        return MaterialPageRoute(builder: (ctx) {
          final isLoggedIn = ctx.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) return const LoginScreen();
          if(args is RouteArguments) {
            return IssueFormScreen(initialData: args.data as Issue? ,mode: args.mode,);
          }
          return const LoginScreen();
        });
      case loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case registerScreen:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
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
