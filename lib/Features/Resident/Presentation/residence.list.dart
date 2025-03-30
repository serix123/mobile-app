import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/paginationControls.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
import 'package:online_reservation/Features/Resident/Domain/resident.repository.dart';
import 'package:provider/provider.dart';

const _tableHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 14,
);

const _tableCellStyle = TextStyle(
  fontSize: 14,
);

class ResidentListScreen extends StatefulWidget {
  static const String screenId = "/residents";
  static const String title = "resident list";
  const ResidentListScreen({super.key});

  @override
  State<ResidentListScreen> createState() => _ResidentListScreenState();
}

class _ResidentListScreenState extends State<ResidentListScreen> {

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ResidentProvider>().getResidents();
    });
  }


  @override
  Widget build(BuildContext context) {
    Provider.of<ResidentProvider>(context, listen: false).getResidents();
    return ResponsiveLayout(
      mobileBody: body(),
      desktopBody: body(),
      title: ResidentListScreen.title,
      currentRoute: ResidentListScreen.screenId,
    );
  }

  Widget body() {
    return Column(
      children: [
        Consumer<ResidentProvider>(
          builder: (context, provider, _) {
            return PaginationControls(
                hasNext: provider.hasNext,
                hasPrevious: provider.hasPrevious,
                onNext: provider.loadNextPage,
                onPrevious: provider.loadPreviousPage);
          },
        ),
        Expanded(
          child: Consumer<ResidentProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return GenericErrorState(
                  errorMessage: provider.error!,
                  onRetry: () => provider.getResidents(),
                );
              }

              if (provider.residents.isEmpty) {
                return const GenericEmptyState(
                  title: 'No Residents Found',
                  description:
                      'No residents are currently registered in the system',
                );
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomCardWhite(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingTextStyle: _tableHeaderStyle,
                        dataTextStyle: _tableCellStyle,
                        columns: const [
                          DataColumn(label: Text('Visitor Name')),
                          DataColumn(label: Text('Resident')),
                          DataColumn(label: Text('Purpose')),
                          DataColumn(label: Text('Visit Date')),
                          DataColumn(label: Text('Check In')),
                          DataColumn(label: Text('Actions')),
                          // DataColumn(label: Text('Status')),
                        ],
                        rows: provider.residents
                            .map((visit) => _buildDataRow(visit))
                            .toList(),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
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
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(Resident resident) {

    return DataRow(
      cells: [
        DataCell(Container(width: (MediaQuery.of(context).size.width / 10) ,child: Text(resident.fullName))),
        DataCell(Container(width: (MediaQuery.of(context).size.width / 10) ,child: Text(resident.userEmail))),
        DataCell(Container(width: (MediaQuery.of(context).size.width / 10) ,child: Text(resident.role))),
        DataCell(Container(width: (MediaQuery.of(context).size.width / 10) ,child: Text(resident.formattedAddress))),
        DataCell(Container(width: (MediaQuery.of(context).size.width / 10) ,child: Text(resident.formattedContact))),
        DataCell(Container(width: (MediaQuery.of(context).size.width / 10) ,child: Text(resident.formattedRegistrationDate))),
        DataCell(
          Container(width: (MediaQuery.of(context).size.width / 10) ,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  color: Colors.blue,
                  onPressed: () => _handleUpdateVisit(context, resident),
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () => _handleDeleteVisit(context, resident.id),
                ),
              ],
            ),
          ),
        ),
        // DataCell(
        //   DropdownButton<String>(
        //     value: visitor.status,
        //     underline: const SizedBox(),
        //     items: const [
        //       DropdownMenuItem(value: 'pending', child: Text('Pending')),
        //       DropdownMenuItem(value: 'approved', child: Text('Approved')),
        //       DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
        //     ],
        //     onChanged: (newStatus) {
        //       if (newStatus != null) {
        //         _handleStatusChange(context, visitor.id, newStatus);
        //       }
        //     },
        //   ),
        // ),
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
        tooltip: icon == Icons.edit ? 'Edit visit' : 'Delete visit',
      ),
    );
  }

  Future<void> _handleDeleteVisit(BuildContext context, int visitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this visit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // await context.read<ResidentProvider>().de(visitId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visit deleted successfully')),
        );
        await context.read<ResidentProvider>().getResidents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _handleUpdateVisit(BuildContext context, Resident resident) {
    // Navigator.of(context).pushNamed(
    //   RouteGenerator.visitorFormScreen,
    //   arguments: VisitorScreenConfig(
    //     mode: FormMode.edit,
    //     onDelete: () async => {
    //       await context.read<VisitProvider>().deleteVisitor(visitor.id),
    //       Navigator.pop(context),
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Visit deleted successfully')),
    //       )
    //     },
    //     initialData: VisitorDTO(
    //         id: visitor.id,
    //         name: visitor.name,
    //         visitDate: visitor.visitDate,
    //         visitPurpose: visitor.visitPurpose),
    //     onSubmit: (v) async =>
    //     await context.read<VisitProvider>().updateVisitor(v),
    //   ),
    // );
  }
}
