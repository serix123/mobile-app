import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Core/Presentation/Components/adminWrapper.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/paginationControls.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedApplication/Domain/application.repository.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/widget/list.item.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/widget/search.widget.dart';
import 'package:online_reservation/config/app.color.dart';
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

  void _initData(BuildContext context) async {
    final task = [
      Provider.of<UserInfoProvider>(context, listen: false).getUserInfo(),
      Provider.of<ApplicationProvider>(context, listen: false).getProfiles(),
    ];
    await Future.wait(task);
  }

  void _applicationHandler(BuildContext context, int id, bool isVerify) async {
    final provider = context.read<ApplicationProvider>();
    if (isVerify) {
      await provider.verifyApplication(id);
    } else {
      await provider.rejectApplication(id);
    }
    await provider.getProfile(id);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData(context);
    });
    return ResponsiveLayout(
      mobileBody: _mobileBody(),
      desktopBody: _desktopBody(),
      title: const Text(title),
      currentRoute: screenId,
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Consumer<ApplicationProvider>(
        builder: (context, provider, child) {
          return SearchFields(
            onSearch: (text, status, gender) {
              provider.getProfiles(gender: gender, query: text, status: status);
            },
          );
        },
      ),
    );
  }

  Widget _mobileBody() {
    return AdminWrapper(
      (context, userInfoProvider) {
        if (userInfoProvider.user == null) {
          return GenericErrorState(
              errorMessage: "User Information not found.",
              onRetry: () => userInfoProvider.getUserInfo());
        }
        return Column(
          children: [
            _searchBar(),
            _paginationControls(),
            Expanded(
              child: Consumer<ApplicationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) return _buildErrorState(provider);
                  if (provider.applications.isEmpty) {
                    return _buildEmptyState(provider);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.applications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final profile = provider.applications[index];
                      return PatientListItem(
                        profile: profile,
                        onApprove: () =>
                            _applicationHandler(context, profile.id!, true),
                        onReject: () =>
                            _applicationHandler(context, profile.id!, false),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _desktopBody() {
    return AdminWrapper(
      (context, userInfoProvider) {
        if (userInfoProvider.user == null) {
          return GenericErrorState(
              errorMessage: "User Information not found.",
              onRetry: () => userInfoProvider.getUserInfo());
        }
        return Expanded(
          child: Center(
            child: Column(
              children: [
                _searchBar(),
                _paginationControls(),
                Consumer<ApplicationProvider>(
                    builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) return _buildErrorState(provider);
                  if (provider.applications.isEmpty) {
                    return _buildEmptyState(provider);
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          dataRowColor: WidgetStateProperty.resolveWith<Color?>(
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
                            if (userInfoProvider.user!.isStaff)
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _paginationControls() {
    return Consumer<ApplicationProvider>(
      builder: (context, provider, _) {
        return PaginationControls(
            hasNext: provider.hasNext,
            hasPrevious: provider.hasPrevious,
            onNext: provider.loadNextPage,
            onPrevious: provider.loadPreviousPage);
      },
    );
  }

  DataRow _buildDataRow(
      {required BuildContext context, required PatientProfile patient}) {
    final isStaff =
        Provider.of<UserInfoProvider>(context, listen: false).user!.isStaff;
    final provider = context.read<ApplicationProvider>();
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
                  icon: Icons.remove_red_eye,
                  color: Colors.teal,
                  onPressed: () => Navigator.of(context).pushNamed(
                      RouteGenerator.patientApplicationScreen,
                      arguments: patient),
                  tooltip: "Open"),
              if (isStaff &&
                  patient.verificationStatus == ApplicationStatus.VERIFIED)
                _buildActionButton(
                    icon: Icons.playlist_add_outlined,
                    color: Colors.teal,
                    onPressed: () => Navigator.of(context).pushNamed(
                        RouteGenerator.medicalRecordFormScreen,
                        arguments: patient.id),
                    tooltip: "Write Record"),
            ],
          ),
        ),
        if (isStaff)
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (patient.verificationStatus ==
                    ApplicationStatus.PENDING) ...[
                  _buildAdminActionButton(
                    icon: Icons.check_circle,
                    color: Colors.blue,
                    onPressed: () =>
                        _applicationHandler(context, patient.id!, true),
                  ),
                  _buildAdminActionButton(
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: () =>
                        _applicationHandler(context, patient.id!, false),
                  ),
                ]
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onPressed,
      required String tooltip}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 40),
      child: IconButton(
          icon: Icon(icon, size: 20),
          color: color,
          onPressed: onPressed,
          tooltip: tooltip),
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
        tooltip: icon == Icons.check_circle ? 'Approve' : 'Reject',
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
