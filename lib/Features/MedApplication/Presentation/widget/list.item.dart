import 'package:flutter/material.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:provider/provider.dart';

class PatientListItem extends StatelessWidget {
  final PatientProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PatientListItem({
    super.key,
    required this.profile,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _buildListItem();
  }

  Widget _buildListItem() {
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Full Name', profile.fullName),
                _buildInfoRow('Email', profile.email ?? ""),
                _buildInfoRow('Address', profile.address ?? ""),
                _buildInfoRow('Contact', profile.contactNumber ?? ""),
                if (profile.dob != null)
                _buildInfoRow('Date of Birth', profile.dob.toString()),
                // _buildInfoRow('Reg. Date', _formatDate(profile.registrationDate)),
                const SizedBox(height: 8),
                if (profile.verificationStatus != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: profile.verificationStatus?.color ?? Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile.verificationStatus!.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 8),
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
