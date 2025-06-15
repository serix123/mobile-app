import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/formContainer.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/text.message.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
import 'package:online_reservation/Features/Resident/Domain/resident.repository.dart';
import 'package:online_reservation/Features/Users/Data/Model/user.model.dart';
import 'package:online_reservation/Features/Users/Domain/user.repository.dart';
import 'package:provider/provider.dart';


const List<String> roles = ['Guard', 'Officer', 'Resident'];

class ResidenceFormScreen extends StatefulWidget {

  static const String screenId = "/ResidenceForm";
  final FormMode mode;
  final Resident? initialData;

  const ResidenceFormScreen({
    super.key,
    this.mode = FormMode.edit,
    this.initialData });

  @override
  _ResidenceFormScreenState createState() => _ResidenceFormScreenState();
}

class _ResidenceFormScreenState extends State<ResidenceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late DateTime _selectedDate;

  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial data if in edit mode
    _firstNameController = TextEditingController(text: widget.initialData?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.initialData?.lastName ?? '');
    _emailController = TextEditingController(text: widget.initialData?.userEmail ?? '');
    _contactController = TextEditingController(text: widget.initialData?.contactNumber ?? '');
    _addressController = TextEditingController(text: widget.initialData?.address ?? '');
    // _selectedDate = widget.initialData?.reportedDate ?? DateTime.now();

    _selectedRole = widget.initialData!.role;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

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


    final resident = Resident(
      id: widget.initialData?.id ?? 0,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      userEmail: _emailController.text,
      address: _addressController.text,
      contactNumber: _contactController.text,
      role: _selectedRole,
      registrationDate: widget.initialData!.registrationDate,
    );
    final user = User(
        id: widget.initialData?.id ?? 0,
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        group: _selectedRole,
    );


    if (mounted) {
      await context.read<ResidentProvider>().updateResident(resident);
      final error = context.read<ResidentProvider>().error;
      if (error == null) {
        Navigator.pop(context, true);
      }else{
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  Future<void> _confirmDelete() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {


                Navigator.pop(context,true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      title: const Text('Update Resident'),
      desktopBody: FormContainer(
        width: MediaQuery.of(context).size.width,
        child: buildForm(context),
      ),
      mobileBody: FormContainer(
        child: buildForm(context),
      ),
      currentRoute: "",
    );
  }

  Widget buildForm(BuildContext context) {
    return Consumer3<UserProvider, ResidentProvider, ProfileProvider>(
      builder: (context, userProvider, residentProvider,profileProvider, child) {
        final isOfficer = profileProvider.user?.isOfficer ?? false;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  enabled: isOfficer,
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter First Name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  enabled: isOfficer,
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  // maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Last Name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  enabled: isOfficer,
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  // maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  enabled: isOfficer,
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                  // maxLines: 2,
                  validator: (value) {
                    return null;
                  },
                ),
                TextFormField(
                  enabled: isOfficer,
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                  validator: (value) {
                    return null;
                  },
                ),
                // Status Dropdown
                const SizedBox(height: 26),
                _buildStatusDropdown(isOfficer),
                const SizedBox(height: 32),
                if (residentProvider.error != null)
                  ErrorText(residentProvider.error!),
                if (userProvider.error != null)
                  ErrorText(userProvider.error!),
                if (widget.mode == FormMode.edit)
                  if (residentProvider.isLoading && userProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        if(isOfficer)
                        ...[ElevatedButton(
                          onPressed: () => _submitForm(),
                          child: const Text('Update Resident'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _confirmDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Delete Resident'),
                        ),]
                      ],
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusDropdown(bool isOfficer) {

    // if(!isOfficer){
    //   return TextFormField(
    //     enabled: false,
    //     controller: TextEditingController(text: _selectedRole),
    //     decoration: InputDecoration(labelText: 'Role', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),)),
    //   );
    // }
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: const InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
      items: roles.map((String role) {
        return DropdownMenuItem<String>(
          enabled: isOfficer,
          value: role,
          child: Text(role),
        );
      }).toList(),
      onChanged:!isOfficer ? null : (String? newValue) => setState(() {
          _selectedRole = newValue!;
        }),
    );
  }
}
