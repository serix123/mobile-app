import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Domain/inventory.repository.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/medicalRecord.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/treatment.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Domain/MedicalRecord.repository.dart';
import 'package:online_reservation/Features/MedicalRecords/Presentation/widget/medicine.modal.dart';
import 'package:provider/provider.dart';

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
  // late List<Medicine> _medicines;
  List<Treatment> _treatments = [];
  late DiagnosisStatus _diagnosisCategory;
  late TextEditingController _diagnosisDetailsController;
  late TextEditingController _notesController;
  DateTime? _followUpDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<InventoryProvider>(context, listen: false)
          .getMedicines();
    });
    // Initialize with existing data if editing
    final initial = widget.initialData;
    _diagnosisCategory = initial?.diagnosisCategory ?? DiagnosisStatus.OTH;
    _diagnosisDetailsController =
        TextEditingController(text: initial?.diagnosisDetails);
    _notesController = TextEditingController(text: initial?.notes);
    _followUpDate = initial?.followUpDate;
    _treatments = initial?.treatments ?? [];
  }

  @override
  void dispose() {
    _diagnosisCategory;
    _diagnosisDetailsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectMedicines() async {
    final selectedMedicines =
        await showMedicineSelectionModal(context: context);
    final List<Treatment> treatments = selectedMedicines.map(
      (medicine) {
        return Treatment(
            prescribedQuantity: 1, // Default value
            dispensedQuantity: 1, // Default value
            frequency: Frequency.bid, // Default value
            medicalRecord: widget.initialData?.id ?? 0,
            medicine: medicine.id);
      },
    ).toList();
    setState(() {
      // _medicines = selectedMedicines;
      _treatments = treatments;
    });
  }

  void _updateTreatment(int index, Treatment updatedTreatment) {
    setState(() {
      _treatments[index] = updatedTreatment;
    });
  }

  void _removeTreatment(int index) {
    setState(() {
      _treatments.removeAt(index);
    });
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

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final shouldSubmit = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap a button
        builder: (ctx) => AlertDialog(
                title: const Text('Confirm Submission'),
                content:
                    const Text('Are you sure you want to submit this form?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Yes, submit')),
                ]));

    if (shouldSubmit != true) return;
    final provider = context.read<MedicalRecordProvider>();

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
      attendingDoctor: widget.initialData?.attendingDoctor ?? 0,
      notes: _notesController.text,
      followUpDate: _followUpDate,
      treatments: _treatments,
    );

    try {
      if (widget.initialData != null) {
        await provider.updateRecord(medicalRecord);
      } else {
        await provider.createRecord(medicalRecord);
      }
      print("error : ${provider.error}");
      if (provider.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Submitted successfully!')));
        }
      }
      await provider.getRecords();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      // Navigate back
      if (mounted) Navigator.pop(context, medicalRecord);
      print('Submitting: ${medicalRecord.toJson()}');
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
            if (_treatments.isEmpty)
              ElevatedButton(
                onPressed: _selectMedicines,
                child: const Text('Select medicines'),
              ),
            if (_treatments.isNotEmpty) ...[
              ..._treatments.asMap().entries.map((entry) {
                final index = entry.key;
                final treatment = entry.value;

                return _buildTreatmentForm(
                  treatment: treatment,
                  onChanged: (updatedTreatment) =>
                      _updateTreatment(index, updatedTreatment),
                  onRemoved: () => _removeTreatment(index),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectMedicines,
                child: const Text('Add More Medicines'),
              ),
            ],

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

  Widget _buildTreatmentForm({
    required Treatment treatment,
    required Function(Treatment) onChanged,
    required VoidCallback onRemoved,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                treatment.medicineName ?? "Generic medicine",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemoved,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: treatment.prescribedQuantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Prescribed Qty.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final num = int.tryParse(value);
                    if (num == null) return 'Enter a valid number';
                    if (num <= 0) return 'Must be positive';
                    return null;
                  },
                  onChanged: (value) {
                    onChanged(treatment.copyWith(
                      prescribedQuantity: int.tryParse(value) ?? 0,
                    ));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: treatment.dispensedQuantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Dispensed Qty',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final num = int.tryParse(value);
                    if (num == null) return 'Enter a valid number';
                    if (num <= 0) return 'Must be positive';
                    if (num > treatment.prescribedQuantity) {
                      return 'Cannot exceed prescribed';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    onChanged(treatment.copyWith(
                      dispensedQuantity: int.tryParse(value) ?? 0,
                    ));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Frequency>(
            value: treatment.frequency!,
            items: Frequency.values.map((freq) {
              return DropdownMenuItem(
                value: freq,
                child: Text(freq.displayName),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Frequency',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value != null) {
                onChanged(treatment.copyWith(frequency: value));
              }
            },
          ),
          if (treatment.dosage != null) ...[
            const SizedBox(height: 16),
            Text(
              'Dosage: ${treatment.dosage}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
