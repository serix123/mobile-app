import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/medicalRecord.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/treatment.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Presentation/MedicalRecord.form.view.dart';
import 'package:provider/provider.dart';

class MedicalRecordScreen extends StatelessWidget {
  static const String screenId = "/medRecord";
  static const String title = "Medical Record";
  final MedicalRecord record;

  const MedicalRecordScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserInfoProvider>(context);
    final isStaff =  provider.user?.isStaff ?? false;

    return ResponsiveLayout(
      mobileBody: body(context),
      desktopBody: body(context),
      title: const Text(title),
      actions: [
        if(isStaff)
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            final config = MedicalRecordFormConfig(
                patientId: record.patient, initialData: record);
            Navigator.of(context).pushNamed(
                RouteGenerator.medicalRecordFormScreen,
                arguments: config);
          },
        )
      ],
    );
  }

  Widget body(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('General Information'),
          _buildInfoCard(
            children: [
              _buildInfoRow('Visit Date', _formatDate(record.visitDate)),
              _buildInfoRow(
                  'Diagnosis Category', record.diagnosisCategory.displayName),
              if (record.diagnosisDetails != null)
                _buildInfoRow('Diagnosis Details', record.diagnosisDetails!),
            ],
          ),
          if (record.treatments.isNotEmpty) ...[
            _buildSectionTitle('Treatment Information'),
            ...record.treatments.map((treatment) => _buildInfoCard(
              children: [
                _buildInfoRow('Medicine', treatment.medicineName ?? "Generic Medicine"),
                _buildInfoRow('Dosage', treatment.dosage ?? 'Not specified'),
                if(treatment.frequency != null)
                _buildInfoRow('Frequency',
                    FrequencyExtension.fromCode(treatment.frequency!.code)?.displayName
                        ?? treatment.frequency!.displayName),
                _buildInfoRow('Quantity',
                    '${treatment.dispensedQuantity}/${treatment.prescribedQuantity}'),
                if (treatment.notes?.isNotEmpty ?? false)
                  _buildInfoRow('Notes', treatment.notes!),
              ],
            )),
          ],
          _buildSectionTitle('Medical Team'),
          _buildInfoCard(
            children: [
              if (record.doctorName != null)
                _buildInfoRow('Attending Doctor', record.doctorName!),
              if (record.attendingDoctor != null)
                _buildInfoRow('Doctor ID', record.attendingDoctor.toString()),
            ],
          ),
          if (record.notes != null) _buildSectionTitle('Additional Notes'),
          if (record.notes != null)
            _buildInfoCard(
              children: [
                Text(record.notes!,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          if (record.followUpDate != null) _buildSectionTitle('Follow Up'),
          if (record.followUpDate != null)
            _buildInfoCard(
              children: [
                _buildInfoRow(
                    'Follow Up Date', _formatDate(record.followUpDate!)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(date);
  }
}
