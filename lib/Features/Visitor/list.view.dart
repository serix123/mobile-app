import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Features/Visitor/Data/Model/visitor.model.dart';

class VisitorListItem extends StatelessWidget {
  final Visitor visitor;
  final Function(String) onStatusChanged;

  const VisitorListItem({
    super.key,
    required this.visitor,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return buildVisitorList();
  }

  Card buildVisitorList() {
    return Card(

      child: Padding(
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
              _buildInfoRow('Check-out', _formatDate(visitor.checkOutTime!)),
            const SizedBox(height: 8),
            // _buildStatusDropdown(),
          ],
        ),
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
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold,)),
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
      onChanged: (value) {
        if (value != null) onStatusChanged(value);
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }
}