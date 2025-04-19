import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/widget/gender.dropdown.widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
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
  late Gender _selectedGender;
  late TextEditingController _contactController;
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;
    _addressController = TextEditingController(text: initial?.address ?? '');
    _selectedGender = Gender.OTHER;
    _contactController =
        TextEditingController(text: initial?.contactNumber ?? '');
    _selectedDate = initial?.dob;
  }

  @override
  void dispose() {
    _addressController.dispose();

    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // if (kIsWeb) {
    //   // Web implementation
    //   final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    //   uploadInput.accept = '.jpg,.jpeg,.png,.pdf'; // Set allowed types
    //   uploadInput.click();
    //
    //   await uploadInput.onChange.first;
    //   if (uploadInput.files!.isNotEmpty) {
    //     final html.File file = uploadInput.files!.first;
    //     final reader = html.FileReader();
    //
    //     reader.readAsArrayBuffer(file);
    //     await reader.onLoadEnd.first;
    //
    //     // Convert to Uint8List
    //     final bytes = reader.result as Uint8List?;
    //     if (bytes != null) {
    //       // Create a pseudo-file for web
    //       _selectedFile = File.fromRawPath(bytes); // Note: This is simplified
    //     }
    //   }
    // } else {
    //   // Mobile/desktop implementation
    //   final result = await FilePicker.platform.pickFiles();
    //   if (result != null && result.files.single.path != null) {
    //     _selectedFile = File(result.files.single.path!);
    //   }
    // }

    final result = await FilePicker.platform.pickFiles(withData: kIsWeb);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
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
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID Proof is required.')),
      );
      return;
    }
    try {
      final profile = PatientProfile(
        // firstName: widget.initialData?.firstName,
        // lastName: widget.initialData?.lastName,
        // email: widget.initialData?.email,
        dob: _selectedDate!,
        address: _addressController.text,
        gender: _selectedGender,
        contactNumber: _contactController.text,
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
                    // Date of birth Field
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
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter address' : null,
                    ),
                    const SizedBox(height: 20),

                    // Contact Number Field
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter Contact Number' : null,
                    ),
                    const SizedBox(height: 20),

                    // Gender DropDown
                    GenderDropdown(
                      value: _selectedGender,
                      onChanged: (Gender? newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                      labelText: 'Gender',
                      hintText: 'Select gender',
                    ),
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
                            if (_selectedFile != null)
                              Flexible(
                                child: Text(
                                  _selectedFile?.name ?? "File Not Found",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            else if (widget.initialData?.idDocument != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.initialData!.idDocument!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            else
                              const Text('No ID proof uploaded'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (applicationProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () {
                          _submitForm();
                          if (applicationProvider.error != null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error: ${applicationProvider.error}')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: applicationProvider.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Apply Profile'),
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
