import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/FormFieldMode.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:online_reservation/Features/Authentication/Presentation/login.view.dart';
import 'package:online_reservation/Features/Authentication/Presentation/register.view.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.list.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.view.dart';
import 'package:online_reservation/Features/Documents/Data/Model/document.model.dart';
import 'package:online_reservation/Features/Documents/Presentation/document.form.dart';
import 'package:online_reservation/Features/Documents/Presentation/document.list.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/Features/Events/Presentation/event.form.dart';
import 'package:online_reservation/Features/Events/Presentation/event.list.dart';
import 'package:online_reservation/Features/Events/Presentation/event.view.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.list.view.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.view.dart';
import 'package:online_reservation/Features/Notice/Data/Model/notice.model.dart';
import 'package:online_reservation/Features/Notice/Presentation/notice.form.dart';
import 'package:online_reservation/Features/Notice/Presentation/notice.list.dart';
import 'package:online_reservation/Features/Notice/Presentation/notice.view.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:online_reservation/Features/Profile/Presentation/profile.view.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
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
  static const noticeListScreen = NoticeListScreen.screenId;
  static const noticeEditScreen = NoticeEditScreen.screenId;
  static const noticeViewScreen = NoticeViewScreen.screenId;
  static const documentListScreen = DocumentListScreen.screenId;
  static const documentEditScreen = DocumentEditScreen.screenId;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case homeScreen:
        return MaterialPageRoute(builder: (ctx) {
          final isLoggedIn = ctx.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) return const LoginScreen();
          return const IssuesListScreen();
        });
      case profileScreen:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case residentListScreen:
        return MaterialPageRoute(builder: (_) => const ResidentListScreen());
      case residenceFormScreen:
        return MaterialPageRoute(builder: (ctx) {
          final isLoggedIn = ctx.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) return const LoginScreen();
          if(args is Resident?) {
            return ResidenceFormScreen(initialData: args);
          }
          return const LoginScreen();
        });
      case documentListScreen:
        return MaterialPageRoute(builder: (_) => const DocumentListScreen());
      case documentEditScreen:
        return MaterialPageRoute(builder: (ctx) {
          final isLoggedIn = ctx.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) return const LoginScreen();
          if(args is DocumentEditScreenConfig) {
            return DocumentEditScreen(document: args.document,category: args.category,);
          }
          return const LoginScreen();
        });
      case noticeListScreen:
        return MaterialPageRoute(builder: (_) => const NoticeListScreen());
      case noticeEditScreen:
        return MaterialPageRoute(builder: (ctx) {
          final isLoggedIn = ctx.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) return const LoginScreen();
          if(args is Notice?) {
            return NoticeEditScreen(notice: args,);
          }
          return const LoginScreen();
        });
      case noticeViewScreen:
        return MaterialPageRoute(builder: (ctx) {
          final isLoggedIn = ctx.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) return const LoginScreen();
          if(args is Notice) {
            return NoticeViewScreen(notice: args,);
          }
          return const LoginScreen();
        });
      case eventListScreen:
        return MaterialPageRoute(builder: (_) => const EventListScreen());
      case eventViewScreen:
        return MaterialPageRoute(builder: (ctx) {
          final isLoggedIn = ctx.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) return const LoginScreen();
          if(args is Event) {
            return EventViewScreen(event: args,);
          }
          return const LoginScreen();
        });
      case eventEditScreen:
        return MaterialPageRoute(builder: (ctx) {
          final isLoggedIn = ctx.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) return const LoginScreen();
          if(args is Event?) {
            return EventEditScreen(event: args,);
          }
          return const LoginScreen();
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
