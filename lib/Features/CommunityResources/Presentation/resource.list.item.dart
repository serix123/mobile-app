import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Features/CommunityResources/Data/Model/community_resources.model.dart';

class ResourceListItem extends StatelessWidget {
  final Resource resource;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  // final Function(String) onStatusChanged;

  const ResourceListItem({
    super.key,
    required this.resource,
    required this.onEdit,
    required this.onDelete,
    // required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return buildResourceList();
  }

  Card buildResourceList() {
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Resource Name', resource.name),
                _buildInfoRow('Description', resource.description),
                _buildInfoRow('Contact', resource.contactInfo),
                _buildInfoRow('In-Charge', resource.manageBy?.fullName ?? ""),
                // _buildInfoRow('Manager', _formatDate(resource.registrationDate)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: resource.status.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(resource.status.icon,color: Colors.white, size: 18,),
                      const SizedBox(width: 8),
                      Text(
                        resource.status.displayName,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
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
            width: 150,
            child: Text('$label: ',
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
