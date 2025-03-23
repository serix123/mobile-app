import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Features/Visitor/Data/Model/visitor.model.dart';

class VisitorListItem extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  // final Function(String) onStatusChanged;

  const VisitorListItem({
    super.key,
    required this.visitor,
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
                _buildInfoRow('Visitor', visitor.name),
                _buildInfoRow('Resident', visitor.residentName),
                _buildInfoRow('Purpose', visitor.visitPurpose),
                _buildInfoRow('Visit Date', _formatDate(visitor.visitDate)),
                if (visitor.checkInTime != null)
                  _buildInfoRow('Check-in', _formatDate(visitor.checkInTime!)),
                if (visitor.checkOutTime != null)
                  _buildInfoRow(
                      'Check-out', _formatDate(visitor.checkOutTime!)),
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

  Widget _buildStatusDropdown() {
    const statusOptions = {
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
    };

    return DropdownButtonFormField<String>(
      value: visitor.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: statusOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {},
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }
}
