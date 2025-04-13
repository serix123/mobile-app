import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedApplication/Domain/application.repository.dart';
import 'package:provider/provider.dart';

class ApplicationForm extends StatefulWidget {
  final PatientProfile? initialData;
  final Function(PatientProfile) onSubmit;
  const ApplicationForm({super.key, this.initialData, required this.onSubmit});

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _villageController;
  late TextEditingController _medicalHistoryController;
  DateTime? _selectedDate;
  File? _idProofImage;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;
    _addressController = TextEditingController(text: initial?.address ?? '');
    _villageController = TextEditingController(text: initial?.village ?? '');
    _medicalHistoryController = TextEditingController(text: initial?.medicalHistory ?? '');
    _selectedDate = initial?.dateOfBirth;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _villageController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _idProofImage = File(pickedFile.path);
        _base64Image = base64Encode(_idProofImage!.readAsBytesSync());
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Birthdate is required.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID Proof is required.')),
      );
      return;
    }
    try {
      final profile = PatientProfile(
        dateOfBirth: _selectedDate!,
        address: _addressController.text,
        village: _villageController.text,
        idProof: IdProof(
          filename: _idProofImage?.path.split('/').last ?? 'id_proof.jpg',
          base64Data: _base64Image!,
        ),
        medicalHistory: _medicalHistoryController.text,
      );

      if (widget.initialData == null) {
        // await context.read<ApplicationProvider>().createApplication(profile);
        widget.onSubmit(profile);
      } else {
        // await context.read<ApplicationProvider>().updateApplication(profile);
        widget.onSubmit(profile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, applicationProvider, child) {
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 30),
          child: CustomCardWhite(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Select Date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter address' : null,
                    ),
                    const SizedBox(height: 20),

                    // Village Field
                    TextFormField(
                      controller: _villageController,
                      decoration: const InputDecoration(
                        labelText: 'Village',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter village' : null,
                    ),
                    const SizedBox(height: 20),

                    // Medical History Field
                    TextFormField(
                      controller: _medicalHistoryController,
                      decoration: const InputDecoration(
                        labelText: 'Medical History',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // ID Proof Upload
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ID Proof', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Upload ID'),
                            ),
                            const SizedBox(width: 16),
                            if (_idProofImage != null)
                              Flexible(
                                child: Text(
                                  _idProofImage!.path.split('/').last,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            else if (widget.initialData?.idProof.filename != null)
                              Text('Current: ${widget.initialData!.idProof.filename}')
                            else
                              const Text('No ID proof uploaded'),
                          ],
                        ),
                        if (_idProofImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _idProofImage!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (!applicationProvider.isLoading) {
                          _submitForm();
                          if (applicationProvider.error != null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${applicationProvider.error}')),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          applicationProvider.isLoading ? const CircularProgressIndicator() : const Text('Apply Profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
