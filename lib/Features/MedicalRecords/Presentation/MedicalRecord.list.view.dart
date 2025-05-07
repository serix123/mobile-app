import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/adminWrapper.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/paginationControls.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/medicalRecord.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Presentation/MedicalRecord.form.view.dart';
import 'package:online_reservation/Features/MedicalRecords/Presentation/widget/list.item.dart';
import 'package:online_reservation/Features/MedicalRecords/Presentation/widget/search.widget.dart';
import 'package:online_reservation/config/app.color.dart';
import 'package:provider/provider.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/MedicalRecords/Domain/MedicalRecord.repository.dart';

const _tableHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 14,
);

const _tableCellStyle = TextStyle(
  fontSize: 14,
);

class MedicalRecordsList extends StatelessWidget with WidgetsBindingObserver {
  static const String screenId = "/medRecords";
  static const String title = "Medical Records";
  const MedicalRecordsList({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserInfoProvider>(context, listen: false).getUserInfo();
      Provider.of<MedicalRecordProvider>(context, listen: false).getRecords();
    });
    return ResponsiveLayout(
      mobileBody: _mobileBody(),
      desktopBody: _desktopBody(),
      title: const Text(title),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Consumer<MedicalRecordProvider>(
        builder: (context, provider, child) {
          return SearchFields(
            onSearch: (text, category) {
              provider.getRecords(query: text, category: category);
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
              errorMessage: "User records not found.",
              onRetry: () => userInfoProvider.getUserInfo());
        }
        return Column(
          children: [
            _searchBar(),
            _paginationControls(),
            Expanded(
              child: Consumer<MedicalRecordProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) return _buildErrorState(provider);
                  if (provider.records.isEmpty) {
                    return _buildEmptyState(provider);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.records.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final record = provider.records[index];
                      final config = MedicalRecordFormConfig(
                          patientId: record.patient, initialData: record);
                      return RecordListItem(
                          record: record,
                          onEdit: () => Navigator.of(context).pushNamed(
                              RouteGenerator.medicalRecordFormScreen,
                              arguments: config),
                          onDelete: () {});
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
              errorMessage: "User records not found.",
              onRetry: () => userInfoProvider.getUserInfo());
        }
        return Expanded(
            child: Center(
          child: Column(
            children: [
              _searchBar(),
              _paginationControls(),
              Consumer<MedicalRecordProvider>(
                  builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) return _buildErrorState(provider);
                if (provider.records.isEmpty) {
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
                          const DataColumn(label: Text('Diagnosis')),
                          const DataColumn(label: Text('Details')),
                          const DataColumn(label: Text('Treatment')),
                          const DataColumn(label: Text('Physician')),
                          const DataColumn(label: Text('Actions')),
                          // DataColumn(label: Text('Status')),
                          if (userInfoProvider.user!.isSuperuser)
                            const DataColumn(label: Text('Admin Actions')),
                        ],
                        rows: provider.records
                            .map((record) =>
                                _buildDataRow(context: context, record: record))
                            .toList()),
                  )),
                );
              }),
            ],
          ),
        ));
      },
    );
  }

  DataRow _buildDataRow(
      {required BuildContext context, required MedicalRecord record}) {
    final isSuperuser =
        Provider.of<UserInfoProvider>(context, listen: false).user!.isSuperuser;
    final provider = context.read<MedicalRecordProvider>();
    return DataRow(
      cells: [
        DataCell(Text(record.patientDetails.fullName)),
        DataCell(Text(record.diagnosisCategory.displayName)),
        DataCell(Text(record.diagnosisDetails ?? "")),
        DataCell(Text(record.treatment ?? "")),
        DataCell(Text(record.doctorName ?? "")),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                  icon: Icons.remove_red_eye,
                  color: kGreenNormal,
                  onPressed: () => Navigator.of(context).pushNamed(
                      RouteGenerator.medicalRecordScreen,
                      arguments: record),
                  tooltip: "Open"),
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
                  onPressed: () {
                    final config = MedicalRecordFormConfig(
                        patientId: record.patient, initialData: record);
                    Navigator.of(context).pushNamed(
                        RouteGenerator.medicalRecordFormScreen,
                        arguments: config);
                  },
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
        tooltip: icon == Icons.edit ? 'Edit record' : 'Delete record',
      ),
    );
  }

  Widget _paginationControls() {
    return Consumer<MedicalRecordProvider>(
      builder: (context, provider, _) {
        return PaginationControls(
            hasNext: provider.hasNext,
            hasPrevious: provider.hasPrevious,
            onNext: provider.loadNextPage,
            onPrevious: provider.loadPreviousPage);
      },
    );
  }

  Widget _buildErrorState(MedicalRecordProvider provider) {
    return GenericErrorState(
        errorMessage: provider.error ?? "Cannot retrieve medical records",
        onRetry: () async => await provider.getRecords());
  }

  Widget _buildEmptyState(MedicalRecordProvider provider) {
    return GenericEmptyState(
      title: 'No Records Found.',
      description: 'When new records are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () => provider.getRecords(),
        child: const Text('Reload'),
      ),
    );
  }
}
