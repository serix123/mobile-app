import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/text.message.dart';
import 'package:online_reservation/Features/Notice/Data/Model/notice.model.dart';
import 'package:online_reservation/Features/Notice/Domain/notice.repository.dart';
import 'package:path/path.dart' show extension;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeEditScreen extends StatefulWidget {
  static const String screenId = "/noticeEdit";
  static const String title = "Notice";
  final Notice? notice;
  const NoticeEditScreen({super.key, this.notice});

  @override
  State<NoticeEditScreen> createState() => _NoticeEditScreenState();
}

class _NoticeEditScreenState extends State<NoticeEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  final _formKey = GlobalKey<FormState>();
  PlatformFile? _selectedFile;
  Uint8List? _selectedFileWeb;
  late var _fileExt;

  @override
  void initState() {
    super.initState();
    final notice = widget.notice;
    _titleController = TextEditingController(text: notice?.title ?? '');
    _detailsController = TextEditingController(text: notice?.details ?? '');
    _fileExt = notice?.imageUrl?.split('.').last ?? "";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
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

  void _submitForm() async {
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

      final notice = Notice(
        id: widget.notice?.id ?? 0,
        title: _titleController.text,
        details: _detailsController.text,
        createdDate: widget.notice?.createdDate ?? DateTime.now(),
        updatedDate: DateTime.now(),
      );
      final provider = context.read<NoticeProvider>();
      try {
        if (widget.notice != null) {
          await provider.updateNotice(notice);
          if (_selectedFile != null) {
            await provider.uploadFile(widget.notice!.id!, _selectedFile!, kIsWeb);
          }
        } else {
          final newItem = await provider.createNotice(notice);
          if (newItem != null && _selectedFile != null) {
            await provider.uploadFile(newItem.id!, _selectedFile!, kIsWeb);
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
          final error = context.read<NoticeProvider>().error;
          if (error == null) {
            Navigator.pop(context, true);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: body(context),
      desktopBody: body(context),
      title: Text(widget.notice == null ? 'Create Notice' : 'Edit Notice'),
      actions: [
        if (widget.notice != null)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Handle delete
              Navigator.pop(context, 'delete');
            },
          ),
      ],
    );
  }

  Widget body(BuildContext context) {
    return Consumer<NoticeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
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
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailsController,
                  decoration: const InputDecoration(
                    labelText: 'Details',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Upload Image'),
                    ),
                    const SizedBox(width: 16),
                    if (_selectedFile != null)
                      ..._buildUploadedImageDisplay()
                    else if (widget.notice?.imageUrl != null &&
                        (_fileExt == "jpg" || _fileExt == "png"))
                      ..._buildImageNetwork()
                    else
                      const Text('No image uploaded'),
                  ],
                ),
                const SizedBox(height: 32),
                if (provider.error != null) ErrorText(provider.error!),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : () => _submitForm(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                        widget.notice == null ? 'Create Notice' : 'Save Changes'),
                  ),
              ],
            ),
          ),
        );
      },
    );
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
                width: 200,
                height: 200,
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
                width: 200,
                height: 200,
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
      Expanded(child: Text(widget.notice!.imageUrl!.split('/').last)),
      const SizedBox(width: 16),
      ClipRRect(
        // Optional: Clip corners for a nicer look
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          widget.notice!.imageUrl!,
          width: 200,
          // Take full width of the card
          height: 200,
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
