import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/search.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/CommunityResources/Data/Model/community_resources.model.dart';
import 'package:online_reservation/Features/CommunityResources/Domain/community_resource.repository.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.list.item.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/resource.view.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:provider/provider.dart';

const _tableHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 14,
);

const _tableCellStyle = TextStyle(
  fontSize: 14,
);

class ResourceListScreen extends StatefulWidget {
  static const String screenId = "/resources";
  static const String title = "Resource Index";
  const ResourceListScreen({super.key});

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ResourceProvider>().getResources();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<ResourceProvider>().getResources(),
        ),
        Consumer<ProfileProvider>(builder: (context, profileProvider, child) {
          final isSuperUser = profileProvider.user!.isSuperuser;
          return isSuperUser
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.resourceFormScreen,
                      arguments: ResourceScreenConfig(
                          mode: FormMode.create,
                          onSubmit: (data) async => await context.read<ResourceProvider>().createResource(data))),
                )
              : const SizedBox.shrink();
        })
      ],
      mobileBody: _buildMobile(),
      desktopBody: _buildTable(),
      title: appBar(),
    );
  }

  Widget appBar() {
    return Row(
      children: [
        const Expanded(flex: 1, child: Text(ResourceListScreen.title)),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Consumer<ResourceProvider>(
              builder: (context, resourceProvider, child) {
                return SearchField(
                  onSearchChanged: (query) => resourceProvider.getResources(query: query),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return Consumer<ResourceProvider>(
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
                  onPressed: () => provider.getResources(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.resources.isEmpty) {
          return const Center(child: Text('No visit requests found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.resources.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final resource = provider.resources[index];
            return ResourceListItem(
              resource: resource,
              onDelete: () => _handleDeleteVisit(context, resource.id!),
              onEdit: () => _handleUpdateVisit(context, resource),
            );
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
              child: Consumer2<ProfileProvider, ResourceProvider>(
                builder: (context, profileProvider, resourceProvider, _) {
                  if (resourceProvider.isLoading) return const Center(child: CircularProgressIndicator());
                  if (resourceProvider.error != null) return _buildErrorState(resourceProvider.error!);
                  if (resourceProvider.resources.isEmpty) return _buildEmptyState();

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomCardWhite(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: _tableHeaderStyle,
                          dataTextStyle: _tableCellStyle,
                          columns: [
                            const DataColumn(label: Text('Resource Name')),
                            const DataColumn(label: Text('Description')),
                            const DataColumn(label: Text('Contact')),
                            const DataColumn(label: Text('Status')),
                            if (profileProvider.user!.isSuperuser) const DataColumn(label: Text('Admin Actions')),
                            // DataColumn(label: Text('Status')),
                          ],
                          rows: resourceProvider.resources.map((resource) => _buildDataRow(resource)).toList(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(Resource resource) {
    final isSuperuser = Provider.of<ProfileProvider>(context, listen: false).user!.isSuperuser;
    return DataRow(
      cells: [
        _buildResponsiveCell(context, resource.name),
        _buildResponsiveCell(context, resource.description),
        _buildResponsiveCell(context, resource.contactInfo),
        DataCell(Text(
          resource.status.displayName,
          style: TextStyle(color: resource.status.color),
        )),

        if (isSuperuser)
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAdminActionButton(
                  icon: Icons.edit,
                  color: Colors.blue,
                  onPressed: () => _handleUpdateVisit(context, resource),
                ),
                _buildAdminActionButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () => _handleDeleteVisit(context, resource.id!),
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

  DataCell _buildResponsiveCell(BuildContext context, String text) {
    return DataCell(
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .18,),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: const TextStyle(fontSize: 14,)
        ),
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
        tooltip: icon == Icons.edit ? 'Edit resource' : 'Delete resource',
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return GenericErrorState(
      errorMessage: error,
      onRetry: () {},
    );
  }

  Widget _buildEmptyState() {
    return const GenericEmptyState(
      title: 'No Resources Found',
      description: 'When new resources are created, they will appear here',
      icon: Icons.assignment_outlined,
    );
  }

  Future<void> _handleDeleteVisit(BuildContext context, int resourceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this resource?'),
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
        await context.read<ResourceProvider>().deleteResource(resourceId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resource deleted successfully')),
        );
        await context.read<ResourceProvider>().getResources();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _handleUpdateVisit(BuildContext context, Resource resource) {
    Navigator.of(context).pushNamed(
      RouteGenerator.resourceFormScreen,
      arguments: ResourceScreenConfig(
        mode: FormMode.edit,
        onDelete: () async => {
          await context.read<ResourceProvider>().deleteResource(resource.id!),
          Navigator.pop(context),
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resource deleted successfully')))
        },
        initialData: resource,
        onSubmit: (data) async => await context.read<ResourceProvider>().updateResource(data),
      ),
    );
  }
}
