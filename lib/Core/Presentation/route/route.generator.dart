import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:online_reservation/Features/Authentication/Presentation/login.view.dart';
import 'package:online_reservation/Features/Authentication/Presentation/register.view.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.list.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.view.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.list.view.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.view.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.form.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.list.view.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.profile.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.view.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/medicalRecord.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Presentation/MedicalRecord.form.view.dart';
import 'package:online_reservation/Features/MedicalRecords/Presentation/MedicalRecord.list.view.dart';
import 'package:online_reservation/Features/MedicalRecords/Presentation/MedicalRecord.view.dart';
import 'package:online_reservation/Features/Profile/Presentation/profile.view.dart';
import 'package:online_reservation/Features/Resident/Presentation/residence.list.dart';
import 'package:online_reservation/Features/Resident/Presentation/residence.view.dart';
import 'package:online_reservation/Features/Users/Presentation/user.list.view.dart';
import 'package:online_reservation/Features/Users/Presentation/user.view.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.list.view.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.view.dart';
import 'package:provider/provider.dart';

class RouteGenerator {
  static const homeScreen = "/Home";
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
  static const applicationList = ApplicationList.screenId;
  static const patientProfileScreen = PatientProfileScreen.screenId;
  static const applicationForm = ApplicationForm.screenId;
  static const patientApplicationScreen = PatientApplicationScreen.screenId;
  static const medicalRecordsList = MedicalRecordsList.screenId;
  static const medicalRecordScreen = MedicalRecordScreen.screenId;
  static const medicalRecordFormScreen = MedicalRecordFormScreen.screenId;


  static Route<dynamic> generateRoute(RouteSettings settings) {

    final args = settings.arguments;

    switch (settings.name) {
      case homeScreen:
        return MaterialPageRoute(builder: (ctx) {
          final authProvider = Provider.of<AuthProvider>(ctx, listen: false);
          final userInfoProvider = Provider.of<UserInfoProvider>(ctx, listen: false);
          final isLoggedIn = authProvider.isLoggedIn;
          final isSuperUser = userInfoProvider.user?.isSuperuser;
          if (!isLoggedIn) return const LoginScreen();
          if(userInfoProvider.user == null) return const LoginScreen();
          return isSuperUser! ? const ApplicationList() : const PatientProfileScreen();
        });

      case applicationList:
        return MaterialPageRoute(builder: (_) => const ApplicationList());

      case patientProfileScreen:
        return MaterialPageRoute(builder: (_) => const PatientProfileScreen());

      case applicationForm:
        if (args is ApplicationFormConfig) {
          return MaterialPageRoute(
            builder: (_) => ApplicationForm(initialData: args.initialData,applicationFormMode: args.applicationFormMode, ),
          );
        }
        return _errorRoute();

      case medicalRecordsList:
        return MaterialPageRoute(builder: (_) => const MedicalRecordsList());

      case medicalRecordScreen:
        if (args is MedicalRecord) {
          return MaterialPageRoute(
            builder: (_) => MedicalRecordScreen(record: args, ),
          );
        }
        return _errorRoute();

      case medicalRecordFormScreen:
        if (args is MedicalRecordFormConfig) {
          return MaterialPageRoute(
            builder: (_) => MedicalRecordFormScreen(initialData: args.initialData,patientId: args.patientId, ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => MedicalRecordFormScreen(patientId: args as int,),
        );

      case patientApplicationScreen:
        if (args is PatientProfile) {
          return MaterialPageRoute(
            builder: (_) => PatientApplicationScreen(profile: args),
          );
        }
        return _errorRoute();

      case loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case registerScreen:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      default:
        return _errorRoute();
    }
  }


  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
        builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: GenericErrorState(
                errorMessage: "Page not found, Go Back.",
                onRetry: () => Navigator.of(context).pop(),
              ),
            ));
  }
}
