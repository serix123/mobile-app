import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/formContainer.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/CommunityResources/Data/Model/community_resources.model.dart';
import 'package:online_reservation/Features/CommunityResources/Domain/community_resource.repository.dart';
import 'package:online_reservation/Features/CommunityResources/Presentation/dropDown.widget.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:provider/provider.dart';

class ResourceScreenConfig {
  FormMode mode;
  Resource? initialData;
  Function(Resource) onSubmit;
  Function()? onDelete;

  ResourceScreenConfig({required this.mode, this.initialData, required this.onSubmit, this.onDelete});
}

class ResourceFormScreen extends StatefulWidget {
  static const String screenId = "/ResourcesForm";
  final FormMode mode;
  final Resource? initialData;
  final Function(Resource) onSubmit;
  final Function()? onDelete;

  const ResourceFormScreen({
    super.key,
    required this.mode,
    this.initialData,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  _ResourceFormScreenState createState() => _ResourceFormScreenState();
}

class _ResourceFormScreenState extends State<ResourceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactInfoController;
  late TextEditingController _descriptionController;
  late ResourceType _selectedType;
  late ResourceStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial data if in edit mode
    _nameController = TextEditingController(text: widget.initialData?.name ?? '');
    _contactInfoController = TextEditingController(text: widget.initialData?.contactInfo ?? '');
    _descriptionController = TextEditingController(text: widget.initialData?.description ?? '');
    _selectedStatus = widget.initialData?.status ?? ResourceStatus.AVAILABLE;
    _selectedType = widget.initialData?.resourceType ?? ResourceType.OTHER;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactInfoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = Resource(
        id: widget.initialData?.id,
        name: _nameController.text,
        contactInfo: _contactInfoController.text,
        description: _descriptionController.text, resourceType: _selectedType, status: _selectedStatus,
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
      title: Text(widget.mode == FormMode.create ? 'Apply Visitor' : 'Update Visitor'),
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
    final resourceProvider = context.watch<ResourceProvider>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name of the Resource'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a resource name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _contactInfoController,
              decoration: const InputDecoration(labelText: 'Contact Details'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a contact info';
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
            Column(
              children: [
                ResourceTypeDropdown(
                  onChanged: (type) => setState(() {
                    _selectedType = type ?? _selectedType;
                  }),
                ),
                const SizedBox(height: 16),
                ResourceStatusDropdown(
                  onChanged: (status) => setState(() {
                    _selectedStatus = status ?? _selectedStatus;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (widget.mode == FormMode.create)
              if (resourceProvider.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                    if (resourceProvider.error == null) {
                      Navigator.of(context).pop();
                    } else {
                      final snackBar =
                          SnackBar(content: Text('Submission Failed. Please try again. ${resourceProvider.error!}'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: const Text('Create Item'),
                ),
            if (widget.mode == FormMode.edit)
              if (resourceProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _submitForm();
                        if (resourceProvider.error == null) {
                          Navigator.of(context).pop();
                        } else {
                          final snackBar = SnackBar(
                              content: Text('Submission Failed. Please try again. ${resourceProvider.error!}'));
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
