import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Core/Presentation/Components/adminWrapper.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/adminWrapper.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedApplication/Domain/application.repository.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:provider/provider.dart';

const _tableHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 14,
);

const _tableCellStyle = TextStyle(
  fontSize: 14,
);

class ApplicationList extends StatelessWidget with WidgetsBindingObserver {
  static const String screenId = "/medApplications";
  static const String title = "Applications";
  const ApplicationList({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserInfoProvider>(context, listen: false).getUserInfo();
      Provider.of<ApplicationProvider>(context, listen: false).getProfiles();
    });
    return ResponsiveLayout(
        mobileBody: _mobileBody(),
        desktopBody: _desktopBody(),
        title: _appBar());
  }

  Widget _appBar() {
    return Text(title);
  }

  Widget _mobileBody() {
    return AdminWrapper(
      (context, userInfoProvider) {
        return Consumer<ApplicationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading)
              return const Center(child: CircularProgressIndicator());
            if (provider.error != null) return _buildErrorState(provider);
            if (provider.applications.isEmpty)
              return _buildEmptyState(provider);
            return Placeholder();
          },
        );
      },
    );
  }

  Widget _desktopBody() {
    return AdminWrapper(
      (context, userInfoProvider) {
        return Expanded(
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: Consumer<ApplicationProvider>(
                      builder: (context, provider, child) {
                    if (provider.isLoading)
                      return const Center(child: CircularProgressIndicator());
                    if (provider.error != null)
                      return _buildErrorState(provider);
                    if (provider.applications.isEmpty)
                      return _buildEmptyState(provider);
                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CustomCardWhite(
                          child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                            headingTextStyle: _tableHeaderStyle,
                            dataTextStyle: _tableCellStyle,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey),
                                bottom: BorderSide(color: Colors.grey),
                              ),
                            ),
                            headingRowColor:
                                WidgetStateProperty.all(Colors.grey.shade100),
                            dataRowColor:
                                WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.08);
                                }
                                return null; // Use default row color
                              },
                            ),
                            columns: [
                              const DataColumn(label: Text('Full Name')),
                              const DataColumn(label: Text('Gender')),
                              const DataColumn(label: Text('Contact')),
                              const DataColumn(label: Text('Address')),
                              const DataColumn(label: Text('Status')),
                              const DataColumn(label: Text('Actions')),
                              if (userInfoProvider.user.isSuperuser)
                                const DataColumn(label: Text('Admin Actions')),
                              // DataColumn(label: Text('Status')),
                            ],
                            rows: provider.applications
                                .map((application) => _buildDataRow(
                                    context: context, patient: application))
                                .toList()),
                      )),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(
      {required BuildContext context, required PatientProfile patient}) {
    final isSuperuser =
        Provider.of<UserInfoProvider>(context, listen: false).user.isSuperuser;
    return DataRow(
      cells: [
        DataCell(Text(patient.fullName)),
        DataCell(Text(patient.gender?.displayName ?? Gender.OTHER.displayName)),
        DataCell(Text(patient.contactNumber ?? "")),
        DataCell(Text(patient.address ?? "")),
        DataCell(Text(patient.verificationStatus?.displayName ??
            ApplicationStatus.PENDING.displayName)),

        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.check_box,
                color: Colors.grey,
                onPressed: () {},
              ),
            ],
          ),
        ),

        if (isSuperuser)
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAdminActionButton(
                  icon: Icons.edit,
                  color: Colors.blue,
                  onPressed: () {},
                ),
                _buildAdminActionButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () {},
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 40),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: color,
        onPressed: onPressed,
        tooltip: icon == Icons.check_box
            ? 'Check In'
            : icon == Icons.exit_to_app
                ? 'Check Out'
                : 'Checked Out',
      ),
    );
  }

  Widget _buildAdminActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 40),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: color,
        onPressed: onPressed,
        tooltip: icon == Icons.edit ? 'Edit visit' : 'Delete visit',
      ),
    );
  }

  Widget _buildErrorState(ApplicationProvider provider) {
    return GenericErrorState(
        errorMessage: provider.error ?? "Cannot retrieve Profiles",
        onRetry: () async => await provider.getProfiles());
  }

  Widget _buildEmptyState(ApplicationProvider provider) {
    return GenericEmptyState(
      title: 'No Profiles Found.',
      description: 'When new users are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () => provider.getProfiles(),
        child: const Text('Reload'),
      ),
    );
  }
}
