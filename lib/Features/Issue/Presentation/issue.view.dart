import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show extension;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:online_reservation/Core/Presentation/Components/FormFieldMode.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/text.message.dart';
import 'package:online_reservation/Core/Presentation/Components/formContainer.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.comment.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Issue/Domain/issue.comment.repository.dart';
import 'package:online_reservation/Features/Issue/Domain/issue.repository.dart';
import 'package:online_reservation/Features/Issue/Presentation/widget/comment.list.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';

class IssueFormScreen extends StatefulWidget {
  static const String screenId = "/IssuesForm";
  final Issue? initialData;
  final FormFieldMode mode;

  const IssueFormScreen({super.key, this.initialData, required this.mode});

  @override
  _IssueFormScreenState createState() => _IssueFormScreenState();
}

class _IssueFormScreenState extends State<IssueFormScreen> {
  // config
  late FormFieldMode formFieldMode;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final TextEditingController _commentController = TextEditingController();
  IssueStatus? _selectedStatus;
  IssuePriority? _selectedPriority;
  PlatformFile? _selectedFile;
  Uint8List? _selectedFileWeb;
  late var _fileExt;

  void _initData() async {
    final task = [
      context
          .read<CommentProvider>()
          .getComments(issueId: widget.initialData!.id!),
    ];
    await Future.wait(task);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initData();
      });
    }
    formFieldMode = widget.mode;
    _titleController =
        TextEditingController(text: widget.initialData?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialData?.description ?? '');
    _selectedStatus = widget.initialData?.status;
    _selectedPriority = widget.initialData?.priority;
    _fileExt = widget.initialData?.imageUrl?.split('.').last ?? "";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    _selectedFile = null;
    super.dispose();
  }

  Future<void> _openDocument(String documentUrl) async {
    // final documentUrl = widget.profile.idDocument;
    final uri = Uri.parse(documentUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.platformDefault); // Opens browser or app
    } else {
      throw 'Could not launch $documentUrl';
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom, // Specify custom type
          allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
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

  Future<void> _submitForm() async {
    // if (_selectedFile == null && widget.initialData?.imageUrl == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Error: ID Proof is required.')));
    //   return;
    // }
    if (_selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Priority is required.')));
      return;
    }
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Status is required.')));
      return;
    }
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

    final pendingIssue = Issue(
      id: widget.initialData?.id ?? 0,
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _selectedPriority!,
      status: _selectedStatus ?? IssueStatus.DRAFT,
    );
    final provider = context.read<IssueProvider>();
    try {
      if (formFieldMode == FormFieldMode.CREATE) {
        final newItem = await provider.createIssue(pendingIssue);

        if (newItem != null && _selectedFile != null) {
          await provider.uploadFile(newItem.id!, _selectedFile!, kIsWeb);
        }
      } else if (formFieldMode == FormFieldMode.UPDATE) {
        await provider.updateIssue(pendingIssue);

        if (_selectedFile != null) {
          await provider.uploadFile(
              widget.initialData!.id!, _selectedFile!, kIsWeb);
        }
        if (_commentController.text.isNotEmpty) {
          final comment = Comment(
              comment: _commentController.text,
              issueId: widget.initialData!.id!);
          await context.read<CommentProvider>().createComment(comment);
          await context
              .read<CommentProvider>()
              .getComments(issueId: widget.initialData!.id!);
        }
      }
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
      if (mounted) {
        final error = context.read<IssueProvider>().error;
        if (error == null) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  Future<void> _submitComment() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Status is required.')));
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

    final pendingIssue = Issue(
      id: widget.initialData!.id,
      title: widget.initialData!.title,
      description: widget.initialData!.description,
      priority: widget.initialData!.priority,
      status: _selectedStatus!,
    );
    final provider = context.read<IssueProvider>();
    try {
      await provider.updateIssue(pendingIssue);
      if (_commentController.text.isNotEmpty) {
        final comment = Comment(
            comment: _commentController.text, issueId: widget.initialData!.id!);
        await context.read<CommentProvider>().createComment(comment);
        await context
            .read<CommentProvider>()
            .getComments(issueId: widget.initialData!.id!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        final error = context.read<IssueProvider>().error;
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Submitted successfully!')));
        }
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
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

    if (confirm != true) return;
    if (mounted) {
      await context.read<IssueProvider>().deleteIssue(widget.initialData!.id!);
      final error = context.read<IssueProvider>().error;
      if (error == null) {
        Navigator.pop(context, true);
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
            child: Consumer<CommentProvider>(
              builder: (context, commentProvider, child) {
                if (commentProvider.isLoading) {
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
                      if (commentProvider.error != null)
                        GenericErrorState(
                          errorMessage: commentProvider.error!,
                          onRetry: () async => await commentProvider
                              .getComments(issueId: widget.initialData!.id!),
                        ),
                      CommentListWidget(comments: commentProvider.comments),
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
    return ResponsiveLayout(
      title: Text(formFieldMode == FormFieldMode.CREATE
          ? 'Report Issue'
          : 'Update Issue'),
      desktopBody: body(),
      mobileBody: body(),
      currentRoute: "",
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            FormContainer(
              width: MediaQuery.of(context).size.width,
              child: buildForm(),
            ),
            _buildCommentSection()
          ],
        ),
      ),
    );
  }

  Widget buildForm() {
    final profileProvider = context.read<ProfileProvider>();
    final isResident = profileProvider.user!.isResident;
    return Consumer<IssueProvider>(
      builder: (context, issueProvider, child) {
        switch (formFieldMode) {
          case FormFieldMode.CREATE:
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          labelText: 'Title of the Issue'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      // maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Dropdowns
                    Row(
                      children: [
                        Expanded(child: buildIssuePriorityDropdown()),
                        const SizedBox(width: 10),
                        Expanded(child: buildIssueStatusDropdown()),
                      ],
                    ),

                    //Image Uploader
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Image Attachment',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Upload Image'),
                            ),
                            const SizedBox(width: 16),
                            if (_selectedFile != null)
                              ..._buildUploadedImageDisplay()
                            else
                              const Text('No image uploaded'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    if (issueProvider.error != null)
                      ErrorText(issueProvider.error!),
                    if (issueProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: issueProvider.isLoading
                            ? null
                            : () => _submitForm(),
                        child: const Text('Create Issue'),
                      ),
                  ],
                ),
              ),
            );
          case FormFieldMode.UPDATE:
            if (!isResident) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        enabled: false,
                        controller: _titleController,
                        decoration: const InputDecoration(
                            labelText: 'Title of the Issue'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        enabled: false,
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        // maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Dropdowns
                      Row(
                        children: [
                          Expanded(child: buildIssuePriorityDropdown()),
                          const SizedBox(width: 10),
                          Expanded(child: buildIssueStatusDropdown()),
                        ],
                      ),
                      const SizedBox(height: 18),

                      //Image Uploader
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Image Attachment',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: widget.initialData?.imageUrl != null
                                    ? () => _openDocument(
                                        widget.initialData!.imageUrl!)
                                    : null,
                                child: const Text('Open Image'),
                              ),
                              const SizedBox(width: 16),
                              if (_selectedFile != null)
                                ..._buildUploadedImageDisplay()
                              else if (widget.initialData?.imageUrl != null &&
                                  (_fileExt == "jpg" || _fileExt == "png"))
                                ..._buildImageNetwork()
                              else
                                const Text('No image uploaded'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      TextFormField(
                        maxLines: 3,
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'Comment',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        // maxLines: 2,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please enter a comment';
                        //   }
                        //   return null;
                        // },
                      ),
                      const SizedBox(height: 12),

                      if (issueProvider.error != null)
                        ErrorText(issueProvider.error!),
                      if (issueProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: issueProvider.isLoading
                              ? null
                              : () => _submitComment(),
                          child: const Text('Update Issue'),
                        ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          labelText: 'Title of the Issue'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      // maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Dropdowns
                    Row(
                      children: [
                        Expanded(child: buildIssuePriorityDropdown()),
                        const SizedBox(width: 10),
                        Expanded(child: buildIssueStatusDropdown()),
                      ],
                    ),
                    const SizedBox(height: 18),

                    //Image Uploader
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Image Attachment',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Upload Image'),
                            ),
                            const SizedBox(width: 16),
                            if (_selectedFile != null)
                              ..._buildUploadedImageDisplay()
                            else if (widget.initialData?.imageUrl != null &&
                                (_fileExt == "jpg" || _fileExt == "png"))
                              ..._buildImageNetwork()
                            else
                              const Text('No image uploaded'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    if (issueProvider.error != null)
                      ErrorText(issueProvider.error!),
                    if (issueProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: issueProvider.isLoading
                            ? null
                            : () => _submitForm(),
                        child: Text(formFieldMode == FormFieldMode.CREATE
                            ? 'Create Issue'
                            : 'Update Issue'),
                      ),
                    const SizedBox(height: 12),
                    if (formFieldMode == FormFieldMode.UPDATE)
                      ElevatedButton(
                        onPressed: _confirmDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete Issue'),
                      ),
                  ],
                ),
              ),
            );
          case FormFieldMode.READ:
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      enabled: false,
                      controller: _titleController,
                      decoration: const InputDecoration(
                          labelText: 'Title of the Issue'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      enabled: false,
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      // maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Dropdowns
                    Row(
                      children: [
                        Expanded(
                            child:
                                buildIssuePriorityDropdown(isReadOnly: true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: buildIssueStatusDropdown(isReadOnly: true)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    //Image Uploader
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Image Attachment',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: widget.initialData?.imageUrl != null
                                  ? () => _openDocument(
                                      widget.initialData!.imageUrl!)
                                  : null,
                              child: const Text('Open Image'),
                            ),
                            const SizedBox(width: 16),
                            if (_selectedFile != null)
                              ..._buildUploadedImageDisplay()
                            else if (widget.initialData?.imageUrl != null &&
                                (_fileExt == "jpg" || _fileExt == "png"))
                              ..._buildImageNetwork()
                            else
                              const Text('No image uploaded'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    if (issueProvider.error != null)
                      ErrorText(issueProvider.error!),
                    if (issueProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                  ],
                ),
              ),
            );
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration:
                      const InputDecoration(labelText: 'Title of the Issue'),
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
                const SizedBox(height: 13),

                // Dropdowns
                Row(
                  children: [
                    Expanded(child: buildIssuePriorityDropdown()),
                    const SizedBox(width: 10),
                    Expanded(child: buildIssueStatusDropdown()),
                  ],
                ),
                const SizedBox(height: 30),

                //Image Uploader
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Image Attachment',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Upload Image'),
                        ),
                        const SizedBox(width: 16),
                        if (_selectedFile != null) ...[
                          Expanded(
                            child: Text(
                              _selectedFile?.name ?? "File Not Found",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.initialData?.imageUrl != null &&
                              (_fileExt == "jpg" || _fileExt == "png"))
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildImageDisplay(),
                              ),
                            )
                        ] else if (widget.initialData?.imageUrl != null)
                          Text(widget.initialData!.imageUrl!.split('/').last)
                        else
                          const Text('No image uploaded'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (issueProvider.error != null)
                  ErrorText(issueProvider.error!),
                if (issueProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed:
                        issueProvider.isLoading ? null : () => _submitForm(),
                    child: Text(formFieldMode == FormFieldMode.CREATE
                        ? 'Create Issue'
                        : 'Update Issue'),
                  ),
                const SizedBox(height: 12),
                if (formFieldMode == FormFieldMode.UPDATE)
                  ElevatedButton(
                    onPressed: _confirmDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete Issue'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildIssueStatusDropdown({bool isReadOnly = false}) {
    final isResident =
        context.read<ProfileProvider>().user?.isResident ?? false;
    return DropdownButtonFormField<IssueStatus?>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Issue Status',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: !isResident
          ? IssueStatus.values
              .where((status) => status != IssueStatus.DRAFT)
              .map((status) {
              return DropdownMenuItem<IssueStatus>(
                value: status,
                child:
                    Text(status.displayName), // Use the extension for display
              );
            }).toList()
          : IssueStatus.values
              .where((status) =>
                  status != IssueStatus.RESOLVED &&
                  status != IssueStatus.IN_PROGRESS)
              .map((status) {
              return DropdownMenuItem<IssueStatus>(
                value: status,
                child:
                    Text(status.displayName), // Use the extension for display
              );
            }).toList(),
      onChanged: isReadOnly
          ? null
          : (IssueStatus? newValue) {
              setState(() {
                _selectedStatus = newValue;
              });
            },
      validator: (IssueStatus? value) {
        if (value == null) {
          return 'Please select an issue status';
        }
        return null;
      },
    );
  }

  Widget buildIssuePriorityDropdown({bool isReadOnly = false}) {
    return DropdownButtonFormField<IssuePriority?>(
      value: _selectedPriority,
      decoration: const InputDecoration(
        labelText: 'Issue Priority',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: IssuePriority.values.map((priority) {
        return DropdownMenuItem<IssuePriority>(
          value: priority,
          child: Text(priority.displayName),
        );
      }).toList(),
      onChanged: isReadOnly
          ? null
          : (IssuePriority? newValue) {
              setState(() {
                _selectedPriority = newValue;
              });
            },
      validator: (IssuePriority? value) {
        if (value == null) {
          return 'Please select an issue status';
        }
        return null;
      },
    );
  }

  Widget _buildImageDisplay() {
    if (kIsWeb && _selectedFileWeb != null) {
      return Image.memory(
        _selectedFileWeb!,
        width: 150,
        height: 150,
        fit: BoxFit.contain,
      );
    } else if (!kIsWeb && _selectedFile?.path != null) {
      return Image.file(
        File(_selectedFile!.path!),
        width: 150,
        height: 150,
        fit: BoxFit.contain,
      );
    } else {
      return const Text('No image selected.');
    }
  }

  Widget _buildCommentSection() {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _showBottomModal(), // Call our modal function
            child: const Text('Show Comments'),
          ),
          const SizedBox(
            height: 5,
          ),
          const Icon(
            Icons.arrow_drop_down_outlined,
            color: Colors.green,
          )
        ],
      ),
    );
    // return Consumer<CommentProvider>(
    //   builder: (context, commentProvider, child) {
    //     if (commentProvider.isLoading)
    //       return const Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     return Column(
    //       children: [
    //         if (commentProvider.error != null)
    //           ErrorText(commentProvider.error!),
    //         CommentListWidget(comments: commentProvider.comments),
    //       ],
    //     );
    //   },
    // );
  }

  List<Widget> _buildUploadedImageDisplay() {
    if (_selectedFile != null) {
      if (kIsWeb) {
        if (_selectedFileWeb != null) {
          return [
            Expanded(
              child: Text(
                _selectedFile?.name ?? "File Not Found",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              // Optional: Clip corners for a nicer look
              borderRadius: BorderRadius.circular(8.0),
              child: Image.memory(
                _selectedFileWeb!,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            )
          ];
        }
      } else {
        if (_selectedFile?.path != null) {
          return [
            Expanded(
              child: Text(
                _selectedFile?.name ?? "File Not Found",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              // Optional: Clip corners for a nicer look
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(_selectedFile!.path!),
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            )
          ];
        }
      }
      return [
        Expanded(
          child: Text(
            _selectedFile?.name ?? "File Not Found",
            overflow: TextOverflow.ellipsis,
          ),
        )
      ];
    }
    return [const Text('No image selected.')];
  }

  List<Widget> _buildImageNetwork() {
    return [
      Expanded(child: Text(widget.initialData!.imageUrl!.split('/').last)),
      const SizedBox(width: 16),
      ClipRRect(
        // Optional: Clip corners for a nicer look
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          widget.initialData!.imageUrl!,
          width: 150,
          // Take full width of the card
          height: 150,
          // Fixed height, adjust as needed
          fit: BoxFit.contain,
          // Cover the area, cropping if necessary
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              alignment: Alignment.center,
              height: 150,
              color: Colors.grey[200],
              child:
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            );
          },
        ),
      )
    ];
  }
}
