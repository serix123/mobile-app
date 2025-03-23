// visits_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
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
  static const String title = "visit requests";
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
    return ResponsiveLayout(
      currentRoute: VisitsListScreen.screenId,
      title: VisitsListScreen.title,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<VisitProvider>().loadVisitors(),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.of(context).pushNamed(
              RouteGenerator.visitorFormScreen,
              arguments: VisitorScreenConfig(
                  mode: FormMode.create,
                  onSubmit: (visitor) => context
                      .read<VisitProvider>()
                      .createVisitor(visitor)
                      .then((_) =>
                          context.read<VisitProvider>().loadVisitors()))),
        )
      ],
      desktopBody: _buildTable(),
      mobileBody: buildConsumer(),
    );
  }

  Consumer<VisitProvider> buildConsumer() {
    return Consumer<VisitProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadVisitors(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.visits.isEmpty) {
          return const Center(child: Text('No visit requests found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.visits.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final visit = provider.visits[index];
            return VisitorListItem(
              visitor: visit,
              onDelete: () => _handleDeleteVisit(context, visit.id),
              onEdit: () => _handleUpdateVisit(context, visit),
            );
          },
        );
      },
    );
  }

  Consumer<VisitProvider> _buildTable() {
    return Consumer<VisitProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading)
          return const Center(child: CircularProgressIndicator());
        if (provider.error != null) return _buildErrorState(provider);
        if (provider.visits.isEmpty) return _buildEmptyState();

        return Center(
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
                  rows: provider.visits
                      .map((visit) => _buildDataRow(visit))
                      .toList(),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
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
    );
  }

  DataRow _buildDataRow(Visitor visitor) {
    String visitDateTime =
        "${DateFormat('yyyy-mm-dd').format(visitor.visitDate.toLocal())} ${DateFormat().add_Hm().format(visitor.visitDate.toLocal())}";
    String checkInDateTime;
    if (visitor.checkInTime != null) {
      checkInDateTime =
          "${DateFormat('yyyy-MM-dd').format(visitor.checkInTime!.toLocal())} ${DateFormat.Hm().format(visitor.checkInTime!.toLocal())}";
    } else {
      checkInDateTime = "N/A"; // Or any default value you prefer
    }
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
              _buildActionButton(
                icon: Icons.edit,
                color: Colors.blue,
                onPressed: () => _handleUpdateVisit(context, visitor),
              ),
              _buildActionButton(
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
        onSubmit: (v) async =>
            await context.read<VisitProvider>().updateVisitor(v),
      ),
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;

  const ResponsiveText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = constraints.maxWidth < 200 ? 12.0 : 14.0;
        return Text(
          text,
          style: TextStyle(fontSize: fontSize),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
