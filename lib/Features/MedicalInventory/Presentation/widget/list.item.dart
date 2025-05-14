import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/adminWrapper.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/inventory.model.dart';
import 'package:online_reservation/Utils/utils.dart';

class InventoryListItem extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onShow;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryListItem({
    super.key,
    required this.medicine,
    required this.onShow,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _buildListItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    return AdminWrapper(
      (context, provider) {
        return Card(
          child: Stack(
            children: [
              GestureDetector(
                onTap: onShow,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Name', medicine.name),
                      _buildInfoRow('Category', medicine.category.name),
                      _buildInfoRow('Quantity',
                          "${medicine.quantity} ${medicine.quantityUnit.displayName}"),
                      _buildInfoRow('Supplier', medicine.supplier.name),
                      _buildInfoRow('Last Restock Date',
                          Utils.formatDateISO(medicine.lastRestockDate)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (provider.user!.isStaff)
              Positioned(
                right: 0,
                top: 0,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Colors.blue),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text('$label:',
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
