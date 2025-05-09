import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedApplication/Domain/application.repository.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/application.form.dart';
import 'package:online_reservation/Utils/utils.dart';
import 'package:provider/provider.dart';

class PatientProfileScreen extends StatelessWidget with WidgetsBindingObserver {
  static const String screenId = "/MedProfile";
  static const String screenTitle = "My Profile";
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the provider instance
    // final userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);

    // Call the method immediately (runs every build - be careful!)
    // userInfoProvider.getUserInfo();

    // This ensures the call only happens once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).getProfiles();
    });

    return Consumer<ApplicationProvider>(
      builder: (context, applProvider, child) {
        if (applProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (applProvider.error != null) {
          return GenericErrorState(
            errorMessage: applProvider.error!,
            onRetry: () => applProvider.getProfiles(),
          );
        }
        if (applProvider.applications.isEmpty) {
          return const GenericEmptyState(
            title: 'No information found',
            description:
                'No information are currently registered in the system',
          );
        }
        final application = applProvider.applications[0];
        return ResponsiveLayout(
          mobileBody: _mobileBody(),
          desktopBody: _desktopBody(),
          title: const Text(screenTitle),
          actions: application.verificationStatus == ApplicationStatus.VERIFIED
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToEditProfile(
                        context, application, ApplicationFormMode.EDIT),
                  ),
                ]
              : [],
        );
      },
    );
  }

  Widget _mobileBody() {
    return Consumer<ApplicationProvider>(builder: (context, provider, child) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (provider.error != null) {
        return GenericErrorState(
          errorMessage: provider.error!,
          onRetry: () => provider.getProfiles(),
        );
      }
      if (provider.applications.isEmpty) {
        return const GenericEmptyState(
          title: 'No information found',
          description: 'No information are currently registered in the system',
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildVerificationStatus(),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildContactInfoSection(),
            ],
          ),
        ),
      );
    });
  }

  Widget _desktopBody() {
    return Consumer<ApplicationProvider>(builder: (context, provider, child) {
      if (provider.isLoading || provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (provider.error != null || provider.error != null) {
        return GenericErrorState(
          errorMessage: provider.error!,
          onRetry: () => provider.getProfiles(),
        );
      }
      if (provider.applications.isEmpty) {
        return const GenericEmptyState(
          title: 'No information found',
          description: 'No information are currently registered in the system',
        );
      }
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
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child:
            Consumer<ApplicationProvider>(builder: (context, provider, child) {
          final application = provider.applications[0];
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
        }),
      ),
    );
  }

  Widget _buildProfileHeader({bool showEmail = false}) {
    return Consumer<ApplicationProvider>(builder: (context, provider, child) {
      final application = provider.applications[0];
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
    });
  }

  Widget _buildPersonalInfoSection({bool showTitle = true}) {
    return Consumer<ApplicationProvider>(builder: (context, provider, child) {
      final application = provider.applications[0];
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
                _buildInfoRow(
                    'Date of Birth', Utils.formatDateISO(application.dob)),
              _buildInfoRow('Gender', application.gender!.displayName),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildContactInfoSection({bool showTitle = true}) {
    return Consumer<ApplicationProvider>(
      builder: (context, provider, child) {
        final application = provider.applications[0];
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
                _buildInfoRow(
                    'Contact Number', application.contactNumber ?? ""),
                _buildInfoRow('Address', application.address ?? ""),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationStatus() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Consumer<ApplicationProvider>(
          builder: (context, provider, child) {
            final application = provider.applications[0];
            final status = application.verificationStatus!;
            return Column(
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
                if (status != ApplicationStatus.VERIFIED)
                  ElevatedButton(
                    onPressed: () =>
                        _navigateToEditProfile(context, application, null),
                    child: const Text('VERIFY ACCOUNT'),
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
            );
          },
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

  void _navigateToEditProfile(BuildContext context, PatientProfile profile,
      ApplicationFormMode? applicationFormMode) {
    final applicationFormConfig = ApplicationFormConfig(
        initialData: profile,
        applicationFormMode: applicationFormMode ?? ApplicationFormMode.VERIFY);
    // Implement navigation to edit profile
    Navigator.of(context).pushNamed(RouteGenerator.applicationForm,
        arguments: applicationFormConfig);
  }

  void _startVerificationProcess() {
    // Implement verification process
  }
}
