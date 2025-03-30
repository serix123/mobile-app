// issues_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Issue/Domain/issue.repository.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.view.dart';
import 'package:online_reservation/Features/Issue/listItem.dart';
import 'package:provider/provider.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';

const _tableHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 14,
);

const _tableCellStyle = TextStyle(
  fontSize: 14,
);

class IssuesListScreen extends StatefulWidget {
  static const String screenId = "/issues";
  static const String title = "issues logs";
  const IssuesListScreen({super.key});

  @override
  State<IssuesListScreen> createState() => _IssuesListScreenState();
}

class _IssuesListScreenState extends State<IssuesListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<IssueProvider>().getIssues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentRoute: IssuesListScreen.screenId,
      title: IssuesListScreen.title,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<IssueProvider>().getIssues(),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.issueFormScreen,
              arguments: IssueScreenConfig(
                  mode: FormMode.create,
                  onSubmit: (issue) => context
                      .read<IssueProvider>()
                      .createIssue(issue)
                      .then((_) => context.read<IssueProvider>().getIssues()))),
        )
      ],
      desktopBody: _buildTable(),
      mobileBody: buildConsumer(),
    );
  }

  Consumer<IssueProvider> buildConsumer() {
    return Consumer<IssueProvider>(
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
                  onPressed: () => provider.getIssues(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.issues.isEmpty) {
          return const Center(child: Text('No visit requests found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.issues.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final issue = provider.issues[index];
            return IssueListItem(
              issue: issue,
              onDelete: () => _handleDeleteVisit(context, issue.id!),
              onEdit: () => _handleUpdateVisit(context, issue),
            );
          },
        );
      },
    );
  }

  Consumer<IssueProvider> _buildTable() {
    return Consumer<IssueProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.error != null) return _buildErrorState(provider);
        if (provider.issues.isEmpty) return _buildEmptyState();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomCardWhite(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: _tableHeaderStyle,
                dataTextStyle: _tableCellStyle,
                columns: const [
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Author')),
                  DataColumn(label: Text('Report Date')),
                  DataColumn(label: Text('Resolve Date')),
                  DataColumn(label: Text('Actions')),
                  // DataColumn(label: Text('Status')),
                ],
                rows: provider.issues.map((visit) => _buildDataRow(visit)).toList(),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                ),
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
                    }
                    return null; // Use default row color
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(Issue issue) {
    String reportedDateTime;
    if (issue.reportedDate != null) {
      reportedDateTime =
          "${DateFormat('yyyy-mm-dd').format(issue.reportedDate!.toLocal())} ${DateFormat().add_Hm().format(issue.reportedDate!.toLocal())}";
    } else {
      reportedDateTime = "N/A"; // Or any default value you prefer
    }

    String resolvedDateTime;
    if (issue.resolvedDate != null) {
      resolvedDateTime =
          "${DateFormat('yyyy-MM-dd').format(issue.resolvedDate!.toLocal())} ${DateFormat.Hm().format(issue.resolvedDate!.toLocal())}";
    } else {
      resolvedDateTime = "N/A"; // Or any default value you prefer
    }
    return DataRow(
      cells: [
        DataCell(Text(issue.title)),
        DataCell(Text(issue.description)),
        DataCell(Text(issue.residentName!)),
        DataCell(Text(issue.reportedDate != null ? reportedDateTime : "-")),
        DataCell(Text(issue.reportedDate != null ? resolvedDateTime : "Pending")),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.edit,
                color: Colors.blue,
                onPressed: () => _handleUpdateVisit(context, issue),
              ),
              _buildActionButton(
                icon: Icons.delete,
                color: Colors.red,
                onPressed: () => _handleDeleteVisit(context, issue.id!),
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

  Widget _buildErrorState(IssueProvider provider) {
    return GenericEmptyState(
      title: 'No Visit Requests',
      description: 'When new visit requests are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.issueFormScreen,
            arguments: IssueScreenConfig(
                mode: FormMode.create, onSubmit: (data) => context.read<IssueProvider>().createIssue(data))),
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
        onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.issueFormScreen,
            arguments: IssueScreenConfig(
                mode: FormMode.create,
                onSubmit: (data) async => await context.read<IssueProvider>().createIssue(data))),
        child: const Text('Create New Visit'),
      ),
    );
  }

  Future<void> _handleDeleteVisit(BuildContext context, int issueId) async {
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
        await context.read<IssueProvider>().deleteIssue(issueId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visit deleted successfully')),
        );
        await context.read<IssueProvider>().getIssues();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _handleUpdateVisit(BuildContext context, Issue issue) {
    Navigator.of(context).pushNamed(
      RouteGenerator.visitorFormScreen,
      arguments: IssueScreenConfig(
        mode: FormMode.edit,
        onDelete: () async => {
          await context.read<IssueProvider>().deleteIssue(issue.id!),
          Navigator.pop(context),
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visit deleted successfully')),
          )
        },
        initialData: Issue(id: issue.id, title: issue.title, description: issue.description),
        onSubmit: (data) async => await context.read<IssueProvider>().updateIssue(data),
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
