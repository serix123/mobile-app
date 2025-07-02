import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, Uint8List;
import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/text.message.dart';
import 'package:online_reservation/Features/Documents/Data/Model/document.model.dart';
import 'package:online_reservation/Features/Documents/Data/Model/category.model.dart';
import 'package:online_reservation/Features/Documents/Domain/category.repository.dart';
import 'package:online_reservation/Features/Documents/Domain/document.repository.dart';
import 'package:online_reservation/Features/Documents/Presentation/Widget/category.list.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:path/path.dart' show extension;
import 'package:provider/provider.dart';

class DocumentEditScreenConfig {
  final Document? document;
  final Category? category;
  DocumentEditScreenConfig({
    this.document,
    this.category,
  });
}

class DocumentEditScreen extends StatefulWidget {
  static const String screenId = "/documentEdit";
  static const String title = "Document";
  final Document? document;
  final Category? category;
  const DocumentEditScreen({super.key, this.document, this.category});

  @override
  State<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends State<DocumentEditScreen> {
  late final TextEditingController _titleController;
  Category? _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  PlatformFile? _selectedFile;
  Uint8List? _selectedFileWeb;
  late var _fileExt;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.document?.title ?? '');
    _selectedCategory = widget.document?.category ?? widget.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _selectedFile = null;
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom, // Specify custom type
          allowedExtensions: ['pdf'],
          withData: kIsWeb);

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _submitForm() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Category is required.')));
      return;
    }
    if (_formKey.currentState!.validate()) {
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

      final document = Document(
        id: widget.document?.id ?? 0,
        title: _titleController.text,
        category: _selectedCategory!,
        createdAt: widget.document?.createdAt ?? DateTime.now().toLocal(),
        updatedAt: DateTime.now().toLocal(),
      );
      final provider = context.read<DocumentProvider>();
      try {
        if (widget.document != null) {
          await provider.updateDocument(document);
          if (_selectedFile != null) {
            await provider.uploadFile(
                widget.document!.id, _selectedFile!, kIsWeb);
          }
        } else {
          final newItem = await provider.createDocument(document);
          if (newItem != null && _selectedFile != null) {
            await provider.uploadFile(newItem.id, _selectedFile!, kIsWeb);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
          // Navigator.pop(context);
        }
      } finally {
        if (mounted) {
          final error = context.read<DocumentProvider>().error;
          if (error == null) {
            Navigator.pop(context, true);
          }
        }
      }
    }
  }

  Future<void> _handleDeleteIssue(int documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<DocumentProvider>().deleteDocument(documentId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Issue deleted successfully')),
        );
        final error =  context.read<DocumentProvider>().error;
        Navigator.pop(context,true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _showBottomModal() {
    showModalBottomSheet(
      context: context,
      // `isScrollControlled: true` makes the modal take up more height if its content grows.
      // Otherwise, it defaults to a fixed height (around half the screen).
      isScrollControlled: true,
      builder: (BuildContext context) {
        // This is the content of your bottom modal sheet
        return FractionallySizedBox(
          heightFactor: 0.75,
          widthFactor: 0.9,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                if (categoryProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Comments",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (categoryProvider.error != null)
                        GenericErrorState(
                          errorMessage: categoryProvider.error!,
                          onRetry: () async =>
                              await categoryProvider.getCategories(),
                        ),
                      // CategoryListWidget(categories: categoryProvider.categories,),
                      ListView.separated(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryProvider.categories.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final category = categoryProvider.categories[index];
                          return ListTile(
                            title: Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOfficer = context.read<ProfileProvider>().user?.isOfficer ?? false;
    return ResponsiveLayout(
      currentRoute: DocumentEditScreen.screenId,
      title: const Text(DocumentEditScreen.title),
      desktopBody: body(),
      mobileBody: body(),
      actions: [
        if (widget.document != null && isOfficer)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Handle delete
              _handleDeleteIssue(widget.document!.id);
            },
          ),
      ],
    );
  }

  Widget body() {
    return Consumer2<DocumentProvider, CategoryProvider>(
      builder: (context, documentProvider, categoryProvider, child) {
        if (documentProvider.isLoading || categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Document Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter document name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                categoryText(),
                // const SizedBox(height: 16),
                // _buildDocumentCategoryDropdown(categories:categoryProvider.categories),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Upload document'),
                    ),
                    const SizedBox(width: 16),
                    if (_selectedFile != null)
                      _buildUploadedImageDisplay()
                    else if (widget.document?.documentUrl != null)
                      _buildImageNetwork()
                    else
                      const Text('No document uploaded'),
                  ],
                ),
                const SizedBox(height: 32),
                if (documentProvider.error != null)
                  ErrorText(documentProvider.error!),
                if (documentProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed:
                        documentProvider.isLoading ? null : () => _submitForm(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(widget.document == null
                        ? 'Create Document'
                        : 'Save Changes'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget categoryText() {
    return GestureDetector(
                onTap: _selectedCategory== null ? _showBottomModal : null,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Document Category',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                        text: _selectedCategory?.name ?? "Category"),
                    readOnly: true,
                  ),
                ),
              );
  }

  Widget _buildDocumentCategoryDropdown(
      {bool isReadOnly = false, required List<Category> categories}) {
    return DropdownButtonFormField<Category?>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(category.name), // Use the extension for display
        );
      }).toList(),
      onChanged: isReadOnly
          ? null
          : (Category? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
      validator: (Category? value) {
        if (value == null) {
          return 'Please select an issue status';
        }
        return null;
      },
    );
  }

  Widget _buildUploadedImageDisplay() {
    if (_selectedFile != null) {
      if (kIsWeb) {
        if (_selectedFileWeb != null) {
          return Expanded(
            child: Text(
              _selectedFile?.name ?? "File Not Found",
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      } else {
        if (_selectedFile?.path != null) {
          return Expanded(
            child: Text(
              _selectedFile?.name ?? "File Not Found",
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      }
      return Expanded(
        child: Text(
          _selectedFile?.name ?? "File Not Found",
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return const Text('No File selected.');
  }

  Widget _buildImageNetwork() {
    return Expanded(child: Text(widget.document!.documentUrl!.split('/').last));
  }
}
