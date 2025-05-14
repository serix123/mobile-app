import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedApplication/Domain/application.repository.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.form.dart';
import 'package:online_reservation/config/app.color.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientApplicationScreen extends StatefulWidget {
  static const String screenId = "/ViewProfile";
  static const String screenTitle = "View Profile";
  final PatientProfile profile;
  const PatientApplicationScreen({super.key, required this.profile});

  @override
  State<PatientApplicationScreen> createState() =>
      _PatientApplicationScreenState();
}

class _PatientApplicationScreenState extends State<PatientApplicationScreen> {
  late PatientProfile _profile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    _profile = widget.profile;
  }

  void _loadData() async {
    await Future.wait([
      Provider.of<UserInfoProvider>(context, listen: false).getUserInfo(),
      Provider.of<ApplicationProvider>(context, listen: false)
          .getProfile(widget.profile.id!)
    ]);
  }

  void _verifyApplication() async {
    final provider = context.read<ApplicationProvider>();
    await provider.verifyApplication(_profile.id!);
    await provider.getProfile(_profile.id!);
    final application = provider.applications.firstWhere(
      (e) => e.id == _profile.id,
    );
    setState(() {
      _profile = _profile.copyWith(application);
    });
  }

  void _rejectApplication() async {
    final provider = context.read<ApplicationProvider>();
    await provider.rejectApplication(_profile.id!);
    await provider.getProfile(_profile.id!);
    final application = provider.applications.firstWhere(
      (e) => e.id == _profile.id,
    );
    setState(() {
      _profile = _profile.copyWith(application);
    });
  }

  void _resetApplication() async {
    final provider = context.read<ApplicationProvider>();
    await provider.resetApplication(_profile.id!);
    await provider.getProfile(_profile.id!);
    final application = provider.applications.firstWhere(
      (e) => e.id == _profile.id,
    );
    setState(() {
      _profile = _profile.copyWith(application);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, applProvider, child) {
        final application = applProvider.applications[0];
        return ResponsiveLayout(
          mobileBody: _mobileBody(),
          desktopBody: _desktopBody(),
          title: const Text(PatientApplicationScreen.screenTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.playlist_add_outlined),
              onPressed: () => Navigator.of(context).pushNamed(
                  RouteGenerator.medicalRecordFormScreen,
                  arguments: application.id),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditProfile(
                  context, application, ApplicationFormMode.EDIT),
            ),
          ],
        );
      },
    );
  }

  Widget _mobileBody() {
    return Consumer<ApplicationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) return _buildErrorState(provider);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildVerificationStatus(),
                _buildButtonsRow(),
                const SizedBox(height: 24),
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),
                _buildContactInfoSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _desktopBody() {
    return Consumer<ApplicationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) return _buildErrorState(provider);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  // mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(
                      height: 12,
                    ),
                    _buildVerificationStatus()
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildPersonalInfoSection(showTitle: false),
                    _buildContactInfoSection(showTitle: false),
                    _buildButtonsRow()
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard() {
    final application = _profile;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                application.firstName!.substring(0, 1) +
                    application.lastName!.substring(0, 1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${application.firstName!} ${application.lastName!}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              application.email!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader({bool showEmail = false}) {
    final application = _profile;
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            application.firstName!.substring(0, 1) +
                application.lastName!.substring(0, 1),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${application.firstName!} ${application.lastName!}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          application.email!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection({bool showTitle = true}) {
    final application = _profile;
    return Card(
      elevation: showTitle ? 2 : 0,
      shape: showTitle ? null : const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24),
            ],
            _buildInfoRow('First Name', application.firstName!),
            _buildInfoRow('Last Name', application.lastName!),
            if (application.dob != null)
              _buildInfoRow('Date of Birth', application.dob!.toString()),
            _buildInfoRow('Gender', application.gender!.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection({bool showTitle = true}) {
    final application = _profile;
    return Card(
      elevation: showTitle ? 2 : 0,
      shape: showTitle ? null : const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24),
            ],
            _buildInfoRow('Email', application.email ?? ""),
            _buildInfoRow('Contact Number', application.contactNumber ?? ""),
            _buildInfoRow('Address', application.address ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatus() {
    // final application = context.watch<ApplicationProvider>()
    //     .applications
    //     .firstWhere((e) => e.id == widget.profile.id!);
    final status = _profile.verificationStatus!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              status.icon,
              color: status.color,
            ),
            const SizedBox(width: 16),
            const Text(
              'Account Verification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              status.displayName.toUpperCase(),
              style: TextStyle(
                color: status.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_profile.idDocument != null)
              ElevatedButton(
                onPressed: () => _openDocument(_profile.idDocument!),
                child: const Text('Open Verification Document'),
              ),
            // if (status != ApplicationStatus.VERIFIED) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: status.value,
              backgroundColor: Colors.grey.shade200,
              color: status.color,
            ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (_profile.verificationStatus == ApplicationStatus.PENDING) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // ✅ Make it green
                foregroundColor: Colors.white, // ✅ White text
              ),
              onPressed: _verifyApplication,
              child: const Text('Verify'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal)),
              onPressed: _rejectApplication,
              child: const Text('Reject'),
            ),
          ] else if (_profile.verificationStatus ==
              ApplicationStatus.VERIFIED) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // ✅ Make it green
                foregroundColor: Colors.white, // ✅ White text
              ),
              onPressed: _resetApplication,
              child: const Text('Reset'),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildErrorState(ApplicationProvider provider) {
    return GenericErrorState(
        errorMessage: provider.error ?? "Cannot retrieve Profile",
        onRetry: () async => await provider.getProfile(_profile.id!));
  }

  Future<void> _openDocument(String documentUrl) async {
    // final documentUrl = widget.profile.idDocument;
    final uri = Uri.parse(documentUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.platformDefault); // Opens browser or app
    } else {
      throw 'Could not launch $documentUrl';
    }
  }

  void _navigateToEditProfile(BuildContext context, PatientProfile profile,
      ApplicationFormMode? applicationFormMode) {
    final applicationFormConfig = ApplicationFormConfig(
        initialData: profile,
        applicationFormMode: applicationFormMode ?? ApplicationFormMode.VERIFY);
    // Implement navigation to edit profile
    Navigator.of(context).pushNamed(RouteGenerator.applicationForm,
        arguments: applicationFormConfig);
  }
}
