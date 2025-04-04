import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/paginationControls.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/search.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
import 'package:online_reservation/Features/Resident/Domain/resident.repository.dart';
import 'package:online_reservation/Features/Resident/Presentation/dropDown.widget.dart';
import 'package:online_reservation/Features/Resident/Presentation/list.view.dart';
import 'package:online_reservation/Features/Resident/Presentation/residence.view.dart';
import 'package:online_reservation/Features/Users/Domain/user.repository.dart';
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
    // Provider.of<ResidentProvider>(context, listen: false).getResidents();
    return ResponsiveLayout(
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<ResidentProvider>().getResidents(),
        ),
      ],
      mobileBody: _buildMobile(),
      desktopBody: _buildTable(),
      title: appBar(),
      currentRoute: ResidentListScreen.screenId,
    );
  }

  Widget appBar() {
    return Consumer<ResidentProvider>(
      builder: (context, residentProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SearchField(
                    onSearchChanged: (query) => residentProvider.getResidents(query: query),
                  ),
                ),
                SizedBox(width: isMobile ? 4 : 16, height: isMobile ? 16 : 0),
                Expanded(
                    flex:1,child: RoleFilterDropdown(onRoleChanged: residentProvider.filterByRole)),
              ],
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
                      description: 'No residents are currently registered in the system',
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomCardWhite(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: _tableHeaderStyle,
                          dataTextStyle: _tableCellStyle,
                          columns: const [
                            DataColumn(label: Text('Resident Name')),
                            DataColumn(label: Text('Resident Email')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Address')),
                            DataColumn(label: Text('Contact')),
                            DataColumn(label: Text('Reg. Date')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: provider.residents.map((visit) => _buildDataRow(visit)).toList(),
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

  Widget _buildMobile() {
    return Consumer<ResidentProvider>(
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
                  onPressed: () => provider.getResidents(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.residents.isEmpty) {
          return const Center(child: Text('No visit requests found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.residents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final resident = provider.residents[index];
            return ResidentListItem(
              resident: resident,
              onDelete: () => _handleDeleteVisit(context, resident.id),
              onEdit: () => _handleUpdateVisit(context, resident),
            );
          },
        );
      },
    );
  }

  DataRow _buildDataRow(Resident resident) {
    return DataRow(
      cells: [
        DataCell(Text(resident.fullName)),
        DataCell(Text(resident.userEmail)),
        DataCell(Text(resident.role)),
        DataCell(Text(resident.formattedAddress)),
        DataCell(Text(resident.formattedContact)),
        DataCell(Text(resident.formattedRegistrationDate)),
        DataCell(
          Row(
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
        tooltip: icon == Icons.edit ? 'Edit resident' : 'Delete resident',
      ),
    );
  }

  Future<void> _handleDeleteVisit(BuildContext context, int visitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this resident?'),
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
        await context.read<UserProvider>().deleteUser(visitId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resident deleted successfully')),
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
    Navigator.of(context).pushNamed(
      RouteGenerator.residenceFormScreen,
      arguments: ResidenceScreenConfig(
        onDelete: () async => {
          await context.read<UserProvider>().deleteUser(resident.id),
          Navigator.pop(context),
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resident deleted successfully')),
          )
        },
        initialData: resident,
        onSubmit: (resident, user) async => Future.wait([
          context.read<ResidentProvider>().updateResident(resident),
          context.read<UserProvider>().updateUser(user),
          context.read<ResidentProvider>().getResidents(),
        ]),
        // await context.read<UserProvider>().updateUser(data),
      ),
    );
  }
}
