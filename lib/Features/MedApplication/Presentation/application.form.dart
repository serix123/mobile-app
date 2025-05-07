import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' show extension;
import 'package:provider/provider.dart';
import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedApplication/Domain/application.repository.dart';
import 'package:online_reservation/Features/MedApplication/Presentation/widget/gender.dropdown.widget.dart';

enum ApplicationFormMode { VERIFY, EDIT }

class ApplicationFormConfig {
  final ApplicationFormMode applicationFormMode;
  final PatientProfile initialData;
  const ApplicationFormConfig(
      {required this.initialData,
      this.applicationFormMode = ApplicationFormMode.VERIFY});
}

class ApplicationForm extends StatefulWidget {
  static const String screenId = "/applicationForm";
  static const String screenTitle = "Verify Profile";
  final ApplicationFormMode applicationFormMode;
  final PatientProfile initialData;
  const ApplicationForm(
      {super.key,
      required this.initialData,
      this.applicationFormMode = ApplicationFormMode.VERIFY});

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late Gender _selectedGender;
  late TextEditingController _contactController;
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;
  Uint8List? _selectedFileWeb;
  late var _fileExt;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;
    _firstNameController = TextEditingController(text: initial.firstName ?? '');
    _lastNameController = TextEditingController(text: initial.lastName ?? '');
    _addressController = TextEditingController(text: initial.address ?? '');
    _selectedGender = Gender.OTHER;
    _contactController =
        TextEditingController(text: initial.contactNumber ?? '');
    _selectedDate = initial.dob;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _selectedFile = null;
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

    try {
      final result = await FilePicker.platform.pickFiles(withData: kIsWeb);

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFile = file;
          _selectedFileWeb = file.bytes;
          if (kIsWeb) {
            final parts = file.name.split('.');
            _fileExt = parts.length > 1 ? parts.last : '';
          } else {
            final filePath = file.path;
            _fileExt = extension(filePath!).replaceFirst('.', '');
          }
        });
      }
    } catch (e) {
      print(e);
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
    final provider = context.read<ApplicationProvider>();
    final initial = widget.initialData;

    if (_selectedDate == null && initial.dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Birthdate is required.')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (_selectedFile == null && initial.idDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: ID Proof is required.')));
      return;
    }

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

    try {
      final profile = PatientProfile(
        id: initial.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dob: _selectedDate!,
        address: _addressController.text,
        gender: _selectedGender,
        contactNumber: _contactController.text,
      );
      final List<Future<void>> tasks = [provider.updateApplication(profile)];

      if (_selectedFile != null) {
        tasks.add(provider.uploadFile(initial.id!, _selectedFile!, kIsWeb));
      }

      await Future.wait(tasks);
      await provider.getProfiles();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submitted successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _body(),
      desktopBody: _body(),
      title: const Text(ApplicationForm.screenTitle),
    );
  }

  Widget _body() {
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

                    if (widget.applicationFormMode ==
                        ApplicationFormMode.EDIT) ...[
                      // First Name Field
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter address' : null,
                      ),
                      const SizedBox(height: 20),

                      // Last Name Field
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter address' : null,
                      ),
                      const SizedBox(height: 20),
                    ],

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
                            if (_selectedFile != null) ...[
                              Flexible(
                                child: Text(
                                  _selectedFile?.name ?? "File Not Found",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.initialData.idDocument != null&&(_fileExt == "jpg" || _fileExt == "png"))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildImageDisplay(),
                                  ),
                                )
                            ] else if (widget.initialData.idDocument != null)
                              Text(widget.initialData.idDocument!.split('/').last)
                            else
                              const Text('No ID proof uploaded'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (applicationProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          applicationProvider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: applicationProvider.isLoading
                          ? null
                          : () => _submitForm(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: applicationProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            )
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

  Widget _buildImageDisplay() {
    if (kIsWeb && _selectedFileWeb != null) {
      return Image.memory(
        _selectedFileWeb!,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      );
    } else if (_selectedFile != null) {
      return Image.file(
        File(_selectedFile!.path!),
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      );
    } else {
      return const Text('No image selected.');
    }
  }
}
