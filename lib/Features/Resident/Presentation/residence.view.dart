import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/formContainer.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
import 'package:online_reservation/Features/Resident/Domain/resident.repository.dart';
import 'package:online_reservation/Features/Users/Data/Model/user.model.dart';
import 'package:online_reservation/Features/Users/Domain/user.repository.dart';
import 'package:provider/provider.dart';


const List<String> roles = ['Admin', 'Officer', 'Resident'];

class ResidenceScreenConfig {
  Resident? initialData;
  Function(Resident, User) onSubmit;
  Function()? onDelete;

  ResidenceScreenConfig({this.initialData, required this.onSubmit, this.onDelete});
}

class ResidenceFormScreen extends StatefulWidget {

  static const String screenId = "/ResidenceForm";
  final FormMode mode;
  final Resident? initialData;
  final Function(Resident, User) onSubmit;
  final Function()? onDelete;

  const ResidenceFormScreen({
    super.key,
    this.mode = FormMode.edit,
    this.initialData,
    required this.onSubmit,
    this.onDelete,
  });

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final resident = Resident(
        id: widget.initialData?.id ?? 0,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        userEmail: _emailController.text,
        address: _addressController.text,
        contactNumber: _contactController.text,
        role: widget.initialData!.role,
        registrationDate: widget.initialData!.registrationDate,
      );
      final user = User(
          id: widget.initialData?.id ?? 0,
          email: _emailController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          isStaff: _selectedRole == roles[0]  || _selectedRole == roles[1] ? true : false,
          isSuperuser: _selectedRole == roles[0] ? true : false);
      widget.onSubmit(resident,user);
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
                Navigator.of(context).pop();
                widget.onDelete?.call();
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
    return Consumer2<UserProvider, ResidentProvider>(
      builder: (context, userProvider, residentProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
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
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                  // maxLines: 2,
                  validator: (value) {
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                  validator: (value) {
                    return null;
                  },
                ),
                // Status Dropdown
                const SizedBox(height: 26),
                _buildStatusDropdown(),
                const SizedBox(height: 32),
                if (widget.mode == FormMode.edit)
                  if (residentProvider.isLoading && userProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _submitForm();
                            if (residentProvider.error == null && userProvider.error == null) {
                              Navigator.of(context).pop();
                            } else {
                              final snackBar = SnackBar(
                                  content: Text(
                                      'Submission Failed. Please try again. ${residentProvider.error!} \n${userProvider.error!}'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          child: const Text('Update Resident'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _confirmDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Delete Resident'),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusDropdown() {

    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: const InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
      items: roles.map((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRole = newValue!;
        });
      },
    );
  }
}
