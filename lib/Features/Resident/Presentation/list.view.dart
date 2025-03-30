import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';

class ResidentListItem extends StatelessWidget {
  final Resident resident;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  // final Function(String) onStatusChanged;

  const ResidentListItem({
    super.key,
    required this.resident,
    required this.onEdit,
    required this.onDelete,
    // required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return buildVisitorList();
  }

  Card buildVisitorList() {
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Visitor', resident.fullName),
                _buildInfoRow('Resident', resident.userEmail),
                _buildInfoRow('Purpose', resident.role),
                _buildInfoRow('Purpose', resident.formattedAddress),
                _buildInfoRow('Purpose', resident.formattedContact),
                _buildInfoRow('Visit Date', _formatDate(resident.registrationDate)),
                const SizedBox(height: 8),
                // _buildStatusDropdown(),
              ],
            ),
          ),
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
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }
}