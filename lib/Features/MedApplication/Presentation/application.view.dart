import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Authentication/Data/Model/auth.model.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedApplication/Domain/application.repository.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.form.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/registration.form.dart';
import 'package:provider/provider.dart';

class ApplicationFormScreen extends StatefulWidget {
  static const String screenId = "/applicationForm";
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final screenTitle = "My Profile";
  final PageController _pageController = PageController();
  late PatientProfile _patientProfile;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveLayout(mobileBody: body(context), desktopBody: body(context), title: Text(screenTitle)),
    );
  }

  Widget body(BuildContext context) {
    return ApplicationForm(
      onSubmit: (patientProfile) =>
          _applicationHandler(patientProfile: patientProfile),
    );
    // return Column(
    //   children: [
    //     // Progress indicator
    //     LinearProgressIndicator(
    //       value: (_currentPage + 1) / 2,
    //     ),
    //     Expanded(
    //       child: PageView(
    //         controller: _pageController,
    //         physics: const NeverScrollableScrollPhysics(),
    //         children: [
    //           ApplicationForm(
    //             onSubmit: (patientProfile) => _applicationHandler(patientProfile: patientProfile),
    //           )
    //         ],
    //       ),
    //     ),
    //     // Navigation buttons
    //     Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Row(
    //         children: [
    //           if (_currentPage > 0)
    //             OutlinedButton(
    //               onPressed: _goToPreviousPage,
    //               child: const Text('Back'),
    //             ),
    //           const Spacer(),
    //           ElevatedButton(
    //             onPressed: () => _goToNextPage(),
    //             child: Text(_currentPage == 0 ? 'Continue' : 'Submit'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }

  void _applicationHandler({required PatientProfile patientProfile}) {
    setState(() {
      _patientProfile = patientProfile;
    });
  }

  void _goToNextPage() {
    if (_currentPage == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    } else {
      _submitCombinedForm();
    }
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage--);
  }

  void _submitCombinedForm() async {
    if (mounted) {
      await context
          .read<ApplicationProvider>()
          .updateApplication(_patientProfile);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: ${context.watch<AuthProvider>().error}')),
      // );
    }
  }
}
