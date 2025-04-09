import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/formContainer.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Issue/Domain/issue.repository.dart';
import 'package:provider/provider.dart';


class IssueScreenConfig {
  FormMode mode;
  Issue? initialData;
  Function(Issue) onSubmit;
  Function()? onDelete;

  IssueScreenConfig({required this.mode, this.initialData, required this.onSubmit, this.onDelete});
}

class IssueFormScreen extends StatefulWidget {
  static const String screenId = "/IssuesForm";
  final FormMode mode;
  final Issue? initialData;
  final Function(Issue) onSubmit;
  final Function()? onDelete;

  const IssueFormScreen({
    super.key,
    required this.mode,
    this.initialData,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  _IssueFormScreenState createState() => _IssueFormScreenState();
}

class _IssueFormScreenState extends State<IssueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial data if in edit mode
    _titleController = TextEditingController(text: widget.initialData?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initialData?.description ?? '');
    _selectedDate = widget.initialData?.reportedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

  bool _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = Issue(
        id: widget.initialData?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        // issueDate: _selectedDate,
      );
      widget.onSubmit(newItem);
      return true;
    }
    return false;
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
      title: Text(widget.mode == FormMode.create ? 'Report Issue' : 'Update Issue'),
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

  Padding buildForm(BuildContext context) {
    final issueProvider = context.watch<IssueProvider>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title of the Issue'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              // maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            // Status Dropdown
            const SizedBox(height: 26),
            // const SizedBox(height: 26),
            // Row(
            //   children: [
            //     Text(
            //       'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
            //       style: const TextStyle(fontSize: 16),
            //     ),
            //     TextButton(
            //       onPressed: () => _selectDate(context),
            //       child: const Text('Select Date'),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 32),
            if (widget.mode == FormMode.create)
              if (issueProvider.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () {
                    if(_submitForm()) {
                      if (issueProvider.error == null) {
                        Navigator.of(context).pop();
                      } else {
                        final snackBar = SnackBar(
                            content: Text(
                                'Submission Failed. Please try again. ${issueProvider.error!}'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  },
                  child: const Text('Create Item'),
                ),
            if (widget.mode == FormMode.edit)
              if (issueProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _submitForm();
                        if (issueProvider.error == null) {
                          Navigator.of(context).pop();
                        } else {
                          final snackBar =
                          SnackBar(content: Text('Submission Failed. Please try again. ${issueProvider.error!}'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
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
