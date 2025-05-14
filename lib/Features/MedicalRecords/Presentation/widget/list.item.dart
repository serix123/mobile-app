

import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/medicalRecord.model.dart';
import 'package:online_reservation/Utils/utils.dart';

class RecordListItem extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecordListItem({
    super.key,
    required this.record,
    required this.onEdit,
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
            onTap: () => Navigator.of(context).pushNamed(
                RouteGenerator.medicalRecordScreen,
                arguments: record),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Full Name', record.patientDetails.fullName),
                  _buildInfoRow('Diagnosis', record.diagnosisDetails ?? ""),
                  ...record.treatments.map((treatment) {
                    return _buildInfoRow('Medicine', treatment.medicineName ?? "");
                  },),
                  // _buildInfoRow('Treatment', record.treatments ?? ""),
                  _buildInfoRow('Doctor', record.doctorName ?? ""),
                  _buildInfoRow('Visit Date', Utils.formatDateISO(record.visitDate)),
                  if (record.followUpDate != null)
                    _buildInfoRow('Follow-up Date', Utils.formatDateISO(record.followUpDate)),
                  // _buildInfoRow('Reg. Date', _formatDate(record.registrationDate)),
                  const SizedBox(height: 8),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: record.diagnosisCategory.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      record.diagnosisCategory.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
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