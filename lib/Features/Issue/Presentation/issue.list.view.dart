// issues_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/FormFieldMode.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/paginationControls.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/search.widget.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Issue/Domain/issue.repository.dart';
import 'package:online_reservation/Features/Issue/Presentation/issue.view.dart';
import 'package:online_reservation/Features/Issue/Presentation/widget/listItem.dart';
import 'package:online_reservation/Features/Issue/Presentation/widget/search.widget.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
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
  static const String title = "Issues Logs";
  const IssuesListScreen({super.key});

  @override
  State<IssuesListScreen> createState() => _IssuesListScreenState();
}

class _IssuesListScreenState extends State<IssuesListScreen> {
  void _initData() async {
    final task = [
      context.read<ProfileProvider>().getProfile(),
      context.read<IssueProvider>().getIssues(),
    ];
    await Future.wait(task);
  }

  Future<void> _navigateToForm(BuildContext context, FormFieldMode mode,
      {Issue? issue}) async {
    final result = await Navigator.of(context).pushNamed(
      RouteGenerator.issueFormScreen,
      arguments: RouteArguments(mode: mode, data: issue),
    );

    if (result == true) {
      final task = [
        context.read<ProfileProvider>().getProfile(),
        context.read<IssueProvider>().getIssues(),
      ];
      await Future.wait(task);
    }
  }

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentRoute: IssuesListScreen.screenId,
      title: const Text(IssuesListScreen.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<IssueProvider>().getIssues(),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _navigateToForm(context, FormFieldMode.CREATE),
        )
      ],
      desktopBody: _buildMobile(),
      mobileBody: _buildMobile(),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Consumer<IssueProvider>(
        builder: (context, provider, child) {
          return SearchFields(
            onSearch: (text, status, priority) => provider.getIssues(
                query: text, status: status, priority: priority),
          );
        },
      ),
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        _searchBar(),
        _paginationControls(),
        Expanded(
          child: Consumer2<ProfileProvider, IssueProvider>(
            builder: (context, profileProvider, provider, _) {
              if (profileProvider.isLoading || provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) return _buildErrorState();
              if (provider.issues.isEmpty) return _buildEmptyState();

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.issues.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final issue = provider.issues[index];
                  final isSuperUser = profileProvider.user!.isSuperuser;
                  if (isSuperUser) {
                    return IssueListItem(
                      issue: issue,
                      // onResolve: () => _handleResolveIssue(context, issue.id!),
                      onDelete: () => _handleDeleteIssue(context, issue.id!),
                      onEdit: () => _navigateToForm(
                          context, FormFieldMode.UPDATE,
                          issue: issue),
                      onTap: () => _navigateToForm(context, FormFieldMode.READ,
                          issue: issue),
                    );
                  } else {
                    return IssueListItem(
                      issue: issue,
                      // onResolve: () => _handleResolveIssue(context, issue.id!),
                      onTap: () => _navigateToForm(context, FormFieldMode.READ,
                          issue: issue),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Expanded(
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: Consumer2<ProfileProvider, IssueProvider>(
                builder: (context, profileProvider, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) return _buildErrorState();
                  if (provider.issues.isEmpty) return _buildEmptyState();

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomCardWhite(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: _tableHeaderStyle,
                          dataTextStyle: _tableCellStyle,
                          columns: [
                            const DataColumn(label: Text('Title')),
                            const DataColumn(label: Text('Description')),
                            const DataColumn(label: Text('Author')),
                            const DataColumn(label: Text('Report Date')),
                            const DataColumn(label: Text('Resolve Date')),
                            const DataColumn(label: Text('Actions')),
                            if (profileProvider.user!.isSuperuser)
                              const DataColumn(label: Text('Admin Actions')),
                            // DataColumn(label: Text('Status')),
                          ],
                          rows: provider.issues
                              .map((issue) => _buildDataRow(issue))
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
    final isSuperuser =
        Provider.of<ProfileProvider>(context, listen: false).user!.isSuperuser;
    return DataRow(
      cells: [
        DataCell(Text(issue.title)),
        DataCell(Text(issue.description)),
        DataCell(Text(issue.userFullName!)),
        DataCell(Text(issue.reportedDate != null ? reportedDateTime : "-")),
        DataCell(
            Text(issue.reportedDate != null ? resolvedDateTime : "Ongoing")),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (issue.resolvedDate == null)
                _buildActionButton(
                  icon: Icons.checklist,
                  color: Colors.green,
                  onPressed: () => _handleResolveIssue(context, issue.id!),
                )
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
                  onPressed: () => _navigateToForm(
                      context, FormFieldMode.UPDATE,
                      issue: issue),
                ),
                _buildAdminActionButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () => _handleDeleteIssue(context, issue.id!),
                ),
              ],
            ),
          ),
        // DataCell(
        //   DropdownButton<String>(
        //     value: issueor.status,
        //     underline: const SizedBox(),
        //     items: const [
        //       DropdownMenuItem(value: 'pending', child: Text('Pending')),
        //       DropdownMenuItem(value: 'approved', child: Text('Approved')),
        //       DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
        //     ],
        //     onChanged: (newStatus) {
        //       if (newStatus != null) {
        //         _handleStatusChange(context, issueor.id, newStatus);
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
        tooltip: icon == Icons.checklist ? 'Resolve issue' : 'Ongoing',
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
        tooltip: icon == Icons.edit ? 'Edit issue' : 'Delete issue',
      ),
    );
  }

  Widget _buildErrorState() {
    return GenericEmptyState(
      title: 'No Issue Requests',
      description: 'When new issue requests are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(RouteGenerator.issueFormScreen),
        child: const Text('Create New Issue'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GenericEmptyState(
      title: 'No Issue Requests',
      description: 'When new issue requests are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(RouteGenerator.issueFormScreen),
        child: const Text('Create New Issue'),
      ),
    );
  }

  Future<void> _handleResolveIssue(BuildContext context, int issueId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Resolve'),
        content: const Text('Are you sure you want to resolve this issue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context
            .read<IssueProvider>()
            .resolveIssue(issueId)
            .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Issue resolved successfully')),
                ));
        await context.read<IssueProvider>().getIssues();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resolve failed: $e')),
        );
      }
    }
  }

  Future<void> _handleDeleteIssue(BuildContext context, int issueId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this issue?'),
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
          const SnackBar(content: Text('Issue deleted successfully')),
        );
        await context.read<IssueProvider>().getIssues();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _handleUpdateIssue(BuildContext context, Issue issue) {
    Navigator.of(context).pushNamed(
      RouteGenerator.issueFormScreen,
      arguments: issue,
    );
  }

  Widget _paginationControls() {
    return Consumer<IssueProvider>(
      builder: (context, provider, _) {
        return PaginationControls(
            hasNext: provider.hasNext,
            hasPrevious: provider.hasPrevious,
            onNext: provider.loadNextPage,
            onPrevious: provider.loadPreviousPage);
      },
    );
  }
}
