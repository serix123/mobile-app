import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Features/Authentication/Presentation/login.view.dart';
import 'package:online_reservation/Features/Authentication/Presentation/register.view.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.list.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.view.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.list.view.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.view.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.list.view.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.profile.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.view.dart';
import 'package:online_reservation/Features/Profile/Presentation/profile.view.dart';
import 'package:online_reservation/Features/Resident/Presentation/residence.list.dart';
import 'package:online_reservation/Features/Resident/Presentation/residence.view.dart';
import 'package:online_reservation/Features/Users/Presentation/user.list.view.dart';
import 'package:online_reservation/Features/Users/Presentation/user.view.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.list.view.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.view.dart';
import 'package:provider/provider.dart';

class RouteGenerator {
  // static const homeScreen = MyHomePage.screenId;
  static const loginScreen = LoginScreen.screenId;
  static const registerScreen = RegistrationScreen.screenId;
  static const visitorFormScreen = VisitorFormScreen.screenId;
  static const visitorListScreen = VisitsListScreen.screenId;
  static const issueFormScreen = IssueFormScreen.screenId;
  static const issuesListScreen = IssuesListScreen.screenId;
  static const profileScreen = ProfileScreen.screenId;
  static const residentListScreen = ResidentListScreen.screenId;
  static const residenceFormScreen = ResidenceFormScreen.screenId;
  static const userListScreen = UserListScreen.screenId;
  static const userScreen = UserScreen.screenId;
  static const resourceListScreen = ResourceListScreen.screenId;
  static const resourceFormScreen = ResourceFormScreen.screenId;
  // MedLogix
  static const applicationFormScreen = ApplicationFormScreen.screenId;
  static const applicationList = ApplicationList.screenId;
  static const patientProfileScreen = PatientProfileScreen.screenId;

  static Route<dynamic> generateRoute(RouteSettings settings, bool isLoggedIn, BuildContext context) {
    final userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    final args = settings.arguments;

    if (isLoggedIn) {
      switch (settings.name) {
        case applicationFormScreen:
          return MaterialPageRoute(builder: (_) => const ApplicationFormScreen());
        case applicationList:
          return MaterialPageRoute(builder: (_) => const ApplicationList());
        case patientProfileScreen:
          return MaterialPageRoute(builder: (_) => const PatientProfileScreen());
        // case visitorFormScreen:
        //   if (args is VisitorScreenConfig) {
        //     return MaterialPageRoute(
        //       builder: (_) => VisitorFormScreen(
        //         mode: args.mode,
        //         onSubmit: args.onSubmit,
        //         initialData: args.initialData,
        //         onDelete: args.onDelete,
        //       ),
        //     );
        //   } else {
        //     return MaterialPageRoute(
        //       builder: (_) => VisitorFormScreen(
        //         mode: FormMode.create,
        //         onSubmit: (item) {},
        //         onDelete: () {},
        //       ),
        //     );
        //   }
        //
        // case resourceFormScreen:
        //   if (args is ResourceScreenConfig) {
        //     return MaterialPageRoute(
        //       builder: (_) => ResourceFormScreen(
        //         mode: args.mode,
        //         onSubmit: args.onSubmit,
        //         initialData: args.initialData,
        //         onDelete: args.onDelete,
        //       ),
        //     );
        //   } else {
        //     return MaterialPageRoute(
        //       builder: (_) => ResourceFormScreen(
        //         mode: FormMode.create,
        //         onSubmit: (item) {},
        //         onDelete: () {},
        //       ),
        //     );
        //   }
        // case issueFormScreen:
        //   if (args is IssueScreenConfig) {
        //     return MaterialPageRoute(
        //       builder: (_) => IssueFormScreen(
        //         mode: args.mode,
        //         onSubmit: args.onSubmit,
        //         initialData: args.initialData,
        //         onDelete: args.onDelete,
        //       ),
        //     );
        //   } else {
        //     return MaterialPageRoute(
        //       builder: (_) => IssueFormScreen(
        //         mode: FormMode.create,
        //         onSubmit: (item) {},
        //         onDelete: () {},
        //       ),
        //     );
        //   }
        // case userScreen:
        //   if (args is UserScreenConfig) {
        //     return MaterialPageRoute(
        //       builder: (_) => UserScreen(
        //         user: args.user,
        //       ),
        //     );
        //   } else {
        //     return MaterialPageRoute(
        //       builder: (_) => const UserScreen(
        //         user: null,
        //       ),
        //     );
        //   }
        // case resourceListScreen:
        //   return MaterialPageRoute(builder: (_) => const ResourceListScreen());
        // case residentListScreen:
        //   return MaterialPageRoute(builder: (_) => const ResidentListScreen());
        // case issuesListScreen:
        //   return MaterialPageRoute(builder: (_) => const IssuesListScreen());
        // case visitorListScreen:
        //   return MaterialPageRoute(builder: (_) => const VisitsListScreen());
        // case profileScreen:
        //   return MaterialPageRoute(builder: (_) => const ProfileScreen());
        case loginScreen:
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        default:
          return _errorRoute();
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
