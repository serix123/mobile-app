import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/formContainer.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Visitor/Data/Model/visitor.model.dart';
import 'package:online_reservation/Features/Visitor/Domain/visitor.repository.dart';
import 'package:provider/provider.dart';

class VisitorScreenConfig{
  FormMode mode;
  VisitorDTO? initialData;
  Function(VisitorDTO) onSubmit;
  Function()? onDelete;

  VisitorScreenConfig({required this.mode,this.initialData,required this.onSubmit,this.onDelete });
}

class VisitorFormScreen extends StatefulWidget {
  static const String screenId = "/VisitorForm";
  final FormMode mode;
  final VisitorDTO? initialData;
  final Function(VisitorDTO) onSubmit;
  final Function()? onDelete;

  const VisitorFormScreen({
    super.key,
    required this.mode,
    this.initialData,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  _VisitorFormScreenState createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _purposeController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial data if in edit mode
    _nameController = TextEditingController(text: widget.initialData?.name ?? '');
    _purposeController = TextEditingController(text: widget.initialData?.visitPurpose ?? '');
    _selectedDate = widget.initialData?.visitDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
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
      final newItem = VisitorDTO(
        // id: widget.initialData?.id ?? '',
        name: _nameController.text,
        visitPurpose: _purposeController.text,
        visitDate: _selectedDate,

      );
      widget.onSubmit(newItem);
    }
  }

  Future<void> _confirmDelete() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
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
      title: widget.mode == FormMode.create ? 'Apply Visitor' : 'Update Visitor',
        desktopBody: FormContainer(
          width: MediaQuery.of(context).size.width,
          child: buildForm(context),
        ),
        mobileBody: FormContainer(
          child: buildForm(context),
        ), currentRoute: "",
      );
  }

  Padding buildForm(BuildContext context) {
    final visitProvider = context.watch<VisitProvider>();
    return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name of Visitor'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _purposeController,
                  decoration: const InputDecoration(labelText: 'Purpose of Visitor'),
                  // maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                // Status Dropdown
                SizedBox(height: 26),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',style: const TextStyle(fontSize: 16),),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (widget.mode == FormMode.create)
                  if (visitProvider.isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed:() {
                        _submitForm();
                        if (visitProvider.error == null) {
                          Navigator.of(context).pushReplacementNamed(RouteGenerator.visitorListScreen,
                              arguments: ScreenConfig(mode: FormMode.create, onSubmit: (e) {}));
                        } else {
                          final snackBar = SnackBar(content: Text('Login Failed. Please try again. ${visitProvider.error!}'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: const Text('Create Item'),
                    ),
                if (widget.mode == FormMode.edit)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Update Item'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _confirmDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete Item'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
  }
}