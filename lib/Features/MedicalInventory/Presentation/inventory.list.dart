import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Core/Presentation/Components/adminWrapper.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/paginationControls.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/inventory.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Domain/category.repository.dart';
import 'package:online_reservation/Features/MedicalInventory/Domain/inventory.repository.dart';
import 'package:online_reservation/Features/MedicalInventory/Domain/supplier.repository.dart';
import 'package:online_reservation/Features/MedicalInventory/Presentation/widget/list.item.dart';
import 'package:online_reservation/Features/MedicalInventory/Presentation/widget/search.widget.dart';
import 'package:online_reservation/Utils/utils.dart';
import 'package:online_reservation/config/app.color.dart';
import 'package:provider/provider.dart';

const _tableHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 14,
);

const _tableCellStyle = TextStyle(
  fontSize: 14,
);

class InventoryList extends StatelessWidget with WidgetsBindingObserver {
  static const String screenId = "/inventoryList";
  static const String title = "Inventory";
  const InventoryList({super.key});

  Future<void> _handleDeleteMedicine(
      BuildContext context, int medicineId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
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
        await context.read<InventoryProvider>().deleteMedicine(medicineId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
        await context.read<InventoryProvider>().getMedicines();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _handleShowDetails(BuildContext context, Medicine medicine) {
    // Show medicine details
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(medicine.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${medicine.description}'),
            const SizedBox(height: 8),
            Text(
                'Quantity: ${medicine.quantity} ${medicine.quantityUnit.displayName}'),
            const SizedBox(height: 8),
            Text('Category: ${medicine.category.name}'),
            const SizedBox(height: 8),
            Text('Supplier: ${medicine.supplier.name}'),
            if (medicine.lastRestockDate != null) ...[
              const SizedBox(height: 8),
              Text(
                  'Last Restock: ${Utils.formatDateISO(medicine.lastRestockDate!)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        Provider.of<UserInfoProvider>(context, listen: false).getUserInfo(),
        Provider.of<InventoryProvider>(context, listen: false).getMedicines(),
        Provider.of<CategoryProvider>(context, listen: false).getCategories(),
        Provider.of<SupplierProvider>(context, listen: false).getSuppliers(),
      ]);
    });
    return ResponsiveLayout(
      mobileBody: _mobileBody(),
      desktopBody: _desktopBody(),
      title: const Text(title),
      actions: [

          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(
                  RouteGenerator.inventoryItemScreen);
            },
          )
      ],
      currentRoute: screenId,
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          return SearchFields(
            onSearch: (query) {
              provider.getMedicines(query: query);
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
              child: Consumer<InventoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) return _buildErrorState(provider);
                  if (provider.medicines.isEmpty) {
                    return _buildEmptyState(provider);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.medicines.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final medicine = provider.medicines[index];
                      return InventoryListItem(
                          medicine: medicine,
                          onShow: () => _handleShowDetails(context, medicine),
                          onEdit: () => Navigator.of(context).pushNamed(
                              RouteGenerator.inventoryItemScreen,
                              arguments: medicine),
                          onDelete: () =>
                              _handleDeleteMedicine(context, medicine.id));
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
              Consumer<InventoryProvider>(builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) return _buildErrorState(provider);
                if (provider.medicines.isEmpty) {
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
                          const DataColumn(label: Text('Name')),
                          const DataColumn(label: Text('Category')),
                          const DataColumn(label: Text('Quantity')),
                          const DataColumn(label: Text('Supplier')),
                          const DataColumn(label: Text('Last Restock Date')),
                          const DataColumn(label: Text('Action')),
                          if (userInfoProvider.user!.isStaff)
                            const DataColumn(label: Text('Admin Actions')),
                        ],
                        rows: provider.medicines
                            .map((medicine) => _buildDataRow(
                                context: context, medicine: medicine))
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
      {required BuildContext context, required Medicine medicine}) {
    final isStaff =
        Provider.of<UserInfoProvider>(context, listen: false).user!.isStaff;
    final provider = context.read<InventoryProvider>();
    return DataRow(
      cells: [
        DataCell(Text(medicine.name)),
        DataCell(Text(medicine.category.name)),
        DataCell(
            Text("${medicine.quantity} ${medicine.quantityUnit.displayName}")),
        DataCell(Text(medicine.supplier.name)),
        DataCell(Text(Utils.formatDateISO(medicine.lastRestockDate))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                  icon: Icons.remove_red_eye,
                  color: Colors.teal,
                  onPressed: () => _handleShowDetails(context, medicine),
                  tooltip: "Open"),
            ],
          ),
        ),
        if (isStaff)
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAdminActionButton(
                  icon: Icons.edit,
                  color: Colors.blue,
                  onPressed: () => Navigator.of(context).pushNamed(
                      RouteGenerator.inventoryItemScreen,
                      arguments: medicine),
                ),
                _buildAdminActionButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () => _handleDeleteMedicine(context, medicine.id),
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

  Widget _buildErrorState(InventoryProvider provider) {
    return GenericErrorState(
        errorMessage: provider.error ?? "Cannot retrieve inventory items",
        onRetry: () async => await provider.getMedicines());
  }

  Widget _buildEmptyState(InventoryProvider provider) {
    return GenericEmptyState(
      title: 'No Items Found.',
      description: 'When new items are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () => provider.getMedicines(),
        child: const Text('Reload'),
      ),
    );
  }

  Widget _paginationControls() {
    return Consumer<InventoryProvider>(
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
