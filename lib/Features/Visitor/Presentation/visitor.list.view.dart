// visits_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/search.widget.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:online_reservation/Features/Visitor/Data/Model/visitor.model.dart';
import 'package:provider/provider.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.view.dart';
import 'package:online_reservation/Features/Visitor/list.view.dart';
import 'package:online_reservation/Features/Visitor/Domain/visitor.repository.dart';

const _tableHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 14,
);

const _tableCellStyle = TextStyle(
  fontSize: 14,
);

class VisitsListScreen extends StatefulWidget {
  static const String screenId = "/visitors";
  static const String title = "Visit Logs";
  const VisitsListScreen({super.key});

  @override
  State<VisitsListScreen> createState() => _VisitsListScreenState();
}

class _VisitsListScreenState extends State<VisitsListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<VisitProvider>().loadVisitors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isStaff =
        Provider.of<ProfileProvider>(context, listen: false).user!.isStaff;
    final isSuperuser =
        Provider.of<ProfileProvider>(context, listen: false).user!.isSuperuser;

    return ResponsiveLayout(
      currentRoute: VisitsListScreen.screenId,
      title: appBar(),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<VisitProvider>().loadVisitors(),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () =>
              Navigator.of(context).pushNamed(RouteGenerator.visitorFormScreen,
                  arguments: VisitorScreenConfig(
                      mode: FormMode.create,
                      onSubmit: (visitor) async {
                        if (isStaff ^ isSuperuser) {
                          return await context
                              .read<VisitProvider>()
                              .checkInVisitorOfficer(visitor)
                              .then((_) =>
                                  context.read<VisitProvider>().loadVisitors());
                        }
                        return context
                            .read<VisitProvider>()
                            .createVisitor(visitor)
                            .then((_) =>
                                context.read<VisitProvider>().loadVisitors());
                      })),
        )
      ],
      desktopBody: _buildTable(),
      mobileBody: _buildMobile(),
    );
  }

  Widget appBar() {
    return Row(
      children: [
        const Expanded(flex: 1, child: Text(VisitsListScreen.title)),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Consumer<VisitProvider>(
              builder: (context, visitorProvider, child) {
                return SearchField(
                  onSearchChanged: (query) =>
                      visitorProvider.loadVisitors(query: query),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return Consumer2<ProfileProvider, VisitProvider>(
      builder: (context, profileProvider, provider, _) {
        if (provider.isLoading || profileProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null || profileProvider.error != null) {
          return GenericErrorState(
            errorMessage: provider.error!,
            onRetry: () => provider.loadVisitors(),
          );
        }

        if (provider.visits.isEmpty) {
          return const GenericEmptyState(
            title: 'No Visitors Found',
            description: 'No visitors are currently registered in the system',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.visits.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final visit = provider.visits[index];
            final isSuperUser = profileProvider.user!.isSuperuser;
            if (isSuperUser) {
              return VisitorListItem(
                visitor: visit,
                onCheckIn: () => _handleCheckInVisit(context, visit.id),
                onCheckOut: () => _handleCheckOutVisit(context, visit.id),
                onDelete: () => _handleDeleteVisit(context, visit.id),
                onEdit: () => _handleUpdateVisit(context, visit),
              );
            } else {
              return VisitorListItem(
                visitor: visit,
                onCheckIn: () => _handleCheckInVisit(context, visit.id),
                onCheckOut: () => _handleCheckOutVisit(context, visit.id),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildTable() {
    return Expanded(
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: Consumer2<ProfileProvider, VisitProvider>(
                builder: (context, profileProvider, provider, _) {
                  if (provider.isLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (provider.error != null) return _buildErrorState(provider);
                  if (provider.visits.isEmpty) return _buildEmptyState();

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomCardWhite(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: _tableHeaderStyle,
                          dataTextStyle: _tableCellStyle,
                          columns: [
                            const DataColumn(label: Text('Visitor Name')),
                            const DataColumn(label: Text('Resident')),
                            const DataColumn(label: Text('Purpose')),
                            const DataColumn(label: Text('Visit Date')),
                            const DataColumn(label: Text('Check In')),
                            const DataColumn(label: Text('Actions')),
                            if (profileProvider.user!.isSuperuser)
                              const DataColumn(label: Text('Admin Actions')),
                            // DataColumn(label: Text('Status')),
                          ],
                          rows: provider.visits
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(Visitor visitor) {
    String visitDateTime =
        DateFormat('yyyy-mm-dd').format(visitor.visitDate.toLocal());
    // "${DateFormat('yyyy-mm-dd').format(visitor.visitDate.toLocal())} ${DateFormat().add_Hm().format(visitor.visitDate.toLocal())}";
    String checkInDateTime;
    if (visitor.checkInTime != null) {
      checkInDateTime =
          "${DateFormat('yyyy-MM-dd').format(visitor.checkInTime!.toLocal())} ${DateFormat.Hm().format(visitor.checkInTime!.toLocal())}";
    } else {
      checkInDateTime = "N/A"; // Or any default value you prefer
    }
    final isSuperuser =
        Provider.of<ProfileProvider>(context, listen: false).user!.isSuperuser;
    return DataRow(
      cells: [
        DataCell(Text(visitor.name)),
        DataCell(Text(visitor.residentName)),
        DataCell(Text(visitor.visitPurpose)),
        DataCell(Text(visitDateTime)),
        DataCell(Text(visitor.checkInTime != null ? checkInDateTime : "-")),

        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (visitor.checkInTime == null && visitor.checkOutTime == null)
                _buildActionButton(
                  icon: Icons.check_box,
                  color: Colors.green,
                  onPressed: () => _handleCheckInVisit(context, visitor.id),
                )
              else if (visitor.checkInTime != null &&
                  visitor.checkOutTime == null)
                _buildActionButton(
                  icon: Icons.exit_to_app,
                  color: Colors.red,
                  onPressed: () => _handleCheckOutVisit(context, visitor.id),
                )
              else
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
                  onPressed: () => _handleUpdateVisit(context, visitor),
                ),
                _buildAdminActionButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () => _handleDeleteVisit(context, visitor.id),
                ),
              ],
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
        tooltip: icon == Icons.check_box ? 'Check In' : icon == Icons.exit_to_app ? 'Check Out' : 'Checked Out',
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

  Widget _buildErrorState(VisitProvider provider) {
    return GenericEmptyState(
      title: 'No Visit Requests',
      description: 'When new visit requests are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed(
            RouteGenerator.visitorFormScreen,
            arguments: VisitorScreenConfig(
                mode: FormMode.create,
                onSubmit: (visitor) =>
                    context.read<VisitProvider>().createVisitor(visitor))),
        child: const Text('Create New Visit'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GenericEmptyState(
      title: 'No Visit Requests',
      description: 'When new visit requests are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed(
            RouteGenerator.visitorFormScreen,
            arguments: VisitorScreenConfig(
                mode: FormMode.create,
                onSubmit: (visitor) =>
                    context.read<VisitProvider>().createVisitor(visitor))),
        child: const Text('Create New Visit'),
      ),
    );
  }

  Future<void> _handleCheckInVisit(BuildContext context, int visitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Check In'),
        content: const Text('Are you sure you want to do this action?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Check In'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        Future.wait([
          context
              .read<VisitProvider>()
              .checkInVisitor(visitId)
              .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Visit Checked Out successfully')),
                  )),
          context.read<VisitProvider>().loadVisitors()
        ]);
        // await context.read<VisitProvider>().checkInVisitor(visitId).then((_)=> ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Visit Checked Out successfully')),
        // ));
        // await context.read<VisitProvider>().loadVisitors();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check In failed: $e')),
        );
      }
    }
  }

  Future<void> _handleCheckOutVisit(BuildContext context, int visitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Check Out'),
        content: const Text('Are you sure you want to do this action?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await context
            .read<VisitProvider>()
            .checkOutVisitor(visitId)
            .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Visit Checked Out successfully')),
                ));

        await context.read<VisitProvider>().loadVisitors();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check Out failed: $e')),
        );
      }
    }
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
        await context.read<VisitProvider>().deleteVisitor(visitId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visit deleted successfully')),
        );
        await context.read<VisitProvider>().loadVisitors();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _handleUpdateVisit(BuildContext context, Visitor visitor) {
    Navigator.of(context).pushNamed(
      RouteGenerator.visitorFormScreen,
      arguments: VisitorScreenConfig(
        mode: FormMode.edit,
        onDelete: () async => {
          await context.read<VisitProvider>().deleteVisitor(visitor.id),
          Navigator.pop(context),
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visit deleted successfully')),
          )
        },
        initialData: VisitorDTO(
            id: visitor.id,
            name: visitor.name,
            visitDate: visitor.visitDate,
            visitPurpose: visitor.visitPurpose),
        onSubmit: (visitor) async {
          final isStaff = Provider.of<ProfileProvider>(context, listen: false)
              .user!
              .isStaff;
          final isSuperuser =
              Provider.of<ProfileProvider>(context, listen: false)
                  .user!
                  .isSuperuser;

          if (!isStaff && !isSuperuser) {
            return await context
                .read<VisitProvider>()
                .checkInVisitor(visitor.id!);
          }
          if (!isSuperuser) {
            return await context
                .read<VisitProvider>()
                .checkInVisitorOfficer(visitor);
          }
          return context.read<VisitProvider>().updateVisitor(visitor);
        },
      ),
    );
  }
}
