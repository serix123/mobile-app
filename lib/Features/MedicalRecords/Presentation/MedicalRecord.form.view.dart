import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/medicalRecord.model.dart';

class MedicalRecordFormConfig {
  final int patientId;
  final MedicalRecord? initialData;

  MedicalRecordFormConfig({required this.patientId, this.initialData});
}

class MedicalRecordFormScreen extends StatefulWidget {
  static const String screenId = "/medRecordsForm";

  final int patientId;
  final MedicalRecord? initialData;

  const MedicalRecordFormScreen(
      {super.key, this.initialData, required this.patientId});

  @override
  State<MedicalRecordFormScreen> createState() =>
      _MedicalRecordFormScreenState();
}

class _MedicalRecordFormScreenState extends State<MedicalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>(); // Example categories

  // Controllers
  late DiagnosisStatus _diagnosisCategory;
  late TextEditingController _diagnosisDetailsController;
  late TextEditingController _treatmentController;
  late TextEditingController _notesController;
  DateTime? _followUpDate;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if editing
    final initial = widget.initialData;
    _diagnosisCategory = initial?.diagnosisCategory ?? DiagnosisStatus.OTH;
    _diagnosisDetailsController =
        TextEditingController(text: initial?.diagnosisDetails);
    _treatmentController = TextEditingController(text: initial?.treatment);
    _notesController = TextEditingController(text: initial?.notes);
    _followUpDate = initial?.followUpDate;
  }

  @override
  void dispose() {
    _diagnosisCategory;
    _diagnosisDetailsController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectFollowUpDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() => _followUpDate = pickedDate);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final medicalRecord = MedicalRecord(
        id: widget.initialData?.id ?? 0, // ID would typically come from backend
        patient: widget.patientId,
        patientDetails: widget.initialData?.patientDetails ??
            PatientProfile(
              id: 0,
              firstName: '',
              lastName: '',
              email: '',
              dob: DateTime.now(),
              gender: Gender.OTHER,
              contactNumber: '',
              address: '',
              verificationStatus: ApplicationStatus.UNVERIFIED,
              idDocument: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
        visitDate: DateTime.now(),
        diagnosisCategory: _diagnosisCategory,
        diagnosisDetails: _diagnosisDetailsController.text,
        treatment: _treatmentController.text,
        attendingDoctor: widget.initialData?.attendingDoctor ?? 0,
        notes: _notesController.text,
        followUpDate: _followUpDate,
      );

      // Handle submission (e.g., API call)
      print('Submitting: ${medicalRecord.toJson()}');

      // Navigate back
      Navigator.pop(context, medicalRecord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: body(),
      desktopBody: body(),
      title: Text(widget.initialData == null
          ? 'New Medical Record'
          : 'Edit Medical Record'),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Diagnosis Category
            DropdownButtonFormField<DiagnosisStatus>(
              value: _diagnosisCategory,
              decoration: const InputDecoration(
                labelText: 'Diagnosis Category*',
                border: OutlineInputBorder(),
              ),
              items: DiagnosisStatus.values
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      ))
                  .toList(),
              validator: (value) =>
                  value == null ? 'Please select a diagnosis category' : null,
              onChanged: (DiagnosisStatus? newValue) {
                if (newValue != null) {
                  setState(() {
                    _diagnosisCategory = newValue;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // Details
            TextFormField(
              controller: _diagnosisDetailsController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis Details',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 30),

            // Treatment
            TextFormField(
              controller: _treatmentController,
              decoration: const InputDecoration(
                labelText: 'Treatment',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 30),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _submitForm,
                child: const Text('Save Medical Record'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
