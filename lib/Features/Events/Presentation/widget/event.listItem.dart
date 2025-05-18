

import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/Utils/utils.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onAttend;
  final VoidCallback onDelete;

  const EventListItem({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onAttend,
    required this.onDelete,
  });


  @override
  Widget build(BuildContext context) {
    return _buildListItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Title', event.name),
                  _buildInfoRow('Details', event.details),

                  // _buildInfoRow('Treatment', event.treatments ?? ""),
                  _buildInfoRow('Location', event.location ?? ""),
                  _buildInfoRow('Date', Utils.formatDateISO(event.date)),
                  _buildInfoRow('Attending', "${event.attendeesCount}"),
                  const SizedBox(height: 8),

                ],
              ),
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
                if(!event.isAttending)
                const PopupMenuItem<String>(
                  value: 'attend',
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Attend'),
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
                if (value == 'attend') onAttend();
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
                  overflow: TextOverflow.ellipsis ,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getRoleColor(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'super admin':
        return Colors.red.shade700;
      case 'staff':
        return Theme.of(context).primaryColor;
      default:
        return Colors.grey.shade600;
    }
  }
}