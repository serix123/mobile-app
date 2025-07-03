// event_edit_screen.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/text.message.dart';
import 'package:online_reservation/Utils/utils.dart';
import 'package:path/path.dart' show extension;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/Features/Events/Domain/event.repository.dart';

class EventEditScreen extends StatefulWidget {
  static const String screenId = "/eventEdit";
  static const String title = "Event";
  final Event? event;

  const EventEditScreen({super.key, this.event});

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _detailsController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  Location? _selectedLocation;
  int _selectedDays = 0;
  int _selectedHours = 1;
  int _selectedMinutes = 0;

  late DateTime _endDate;

  final _formKey = GlobalKey<FormState>();

  PlatformFile? _selectedFile;
  Uint8List? _selectedFileWeb;
  late var _fileExt;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _nameController = TextEditingController(text: event?.name ?? '');
    _detailsController = TextEditingController(text: event?.details ?? '');
    _selectedLocation = event?.location;
    _selectedDate = event?.date ?? DateTime.now().toLocal();
    _selectedTime = Utils.roundTimeToNearestQuarter(TimeOfDay.fromDateTime(event?.date ?? DateTime.now().toLocal()));
    _fileExt = event?.imageUrl?.split('.').last ?? "";
    _selectedDays = event?.duration.inDays ?? 0;
    _selectedHours = event != null ? event.duration.inHours % 24 : 0;
    _selectedMinutes = event != null ? event.duration.inMinutes % 60 : 0;
    _endDate = event?.date.add(event.duration) ?? DateTime.now().toLocal().add(Duration(days: _selectedDays,hours: _selectedHours,minutes: _selectedMinutes));

  }

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.event?.date ?? DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateEndDate();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      TimeOfDay roundedTime = Utils.roundTimeToNearestQuarter(picked);
      setState(() {
        _selectedTime = roundedTime;
        _updateEndDate();
      });
    }
  }

  void _updateEndDate() {
    // Combine the selected date + time into the event start DateTime
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Calculate the total duration from selected days, hours, and minutes
    final duration = Duration(
      days: _selectedDays,
      hours: _selectedHours,
      minutes: _selectedMinutes,
    );

    // Compute the end date
    _endDate = startDateTime.add(duration);

    // Optional: call setState() if you're updating a widget that uses _endDate
    // setState(() {});
  }

  void _submitForm() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Location is required.')));
      return;
    }
    if (_formKey.currentState!.validate()) {
      final eventDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

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

      final duration = Duration(days: _selectedDays, hours: _selectedHours, minutes: _selectedMinutes);
      final event = Event(
        id: widget.event?.id ?? 0,
        name: _nameController.text,
        date: eventDate,
        duration: duration,
        details: _detailsController.text,
        location: _selectedLocation!,
        creatorId: widget.event?.creatorId ?? 1, // Get from auth
        creatorName: widget.event?.creatorName ?? 'Current User',
        attendeesCount: widget.event?.attendeesCount ?? 0,
        isAttending: widget.event?.isAttending ?? false,
        createdAt: widget.event?.createdAt ?? DateTime.now().toLocal(),
        updatedAt: DateTime.now().toLocal(),
        // attendeesList: widget.event?.attendeesList ?? []
      );
      final provider = context.read<EventProvider>();
      try {
        if (widget.event != null) {
          await provider.updateEvent(event);
          if (_selectedFile != null) {
            await provider.uploadFile(widget.event!.id, _selectedFile!, kIsWeb);
          }
        } else {
          final newItem = await provider.createEvent(event);
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
          final error = context.read<EventProvider>().error;
          if (error == null) {
            Navigator.pop(context, true);
            Navigator.pop(context, true);
          }
        }
      }
    }
  }

  Future<void> _handleDeleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this event?'),
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
      final provider = context.read<EventProvider>();
      await provider.deleteEvent(widget.event!.id);
      if (provider.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${provider.error}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: body(context),
      desktopBody: body(context),
      title: Text(widget.event == null ? 'Create Event' : 'Edit Event'),
      actions: [
        if (widget.event != null)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _handleDeleteEvent();
            },
          ),
      ],
    );
  }

  Widget body(BuildContext context) {
    return Consumer<EventProvider>(
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
                  controller: _nameController,
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
                _buildLocationDropdown(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  DateFormat('MMM d, y').format(_selectedDate), overflow: TextOverflow.ellipsis,),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedTime.format(context), overflow: TextOverflow.ellipsis,),
                              const Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDuration(),
                const SizedBox(height: 16),
                _buildEndTimeLabel(),
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
                    else if (widget.event?.imageUrl != null &&
                        (_fileExt == "jpg" || _fileExt == "png"))
                      ..._buildImageNetwork()
                    else
                      const Text('No image uploaded', overflow: TextOverflow.ellipsis,),
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
                        widget.event == null ? 'Create Event' : 'Save Changes'),
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
    return [const Text('No image selected.',overflow: TextOverflow.ellipsis,)];
  }

  List<Widget> _buildImageNetwork() {
    return [
      Expanded(child: Text(widget.event!.imageUrl!.split('/').last,overflow: TextOverflow.ellipsis,)),
      const SizedBox(width: 16),
      ClipRRect(
        // Optional: Clip corners for a nicer look
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          widget.event!.imageUrl!,
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

  Widget _buildDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Duration', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                style: const TextStyle(overflow: TextOverflow.ellipsis),
                value: _selectedDays,
                decoration: const InputDecoration(
                  labelText: 'Days',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                items: List.generate(
                  31,
                      (i) => DropdownMenuItem(value: i, child: Text('$i d')),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedDays = value!;
                    _updateEndDate();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                style: const TextStyle(overflow: TextOverflow.ellipsis),
                value: _selectedHours,
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                items: List.generate(
                  24,
                      (i) => DropdownMenuItem(value: i, child: Text('$i hr')),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedHours = value!;
                    _updateEndDate();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                style: const TextStyle(overflow: TextOverflow.ellipsis),
                value: _selectedMinutes,
                decoration: const InputDecoration(
                  labelText: 'Minutes',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                items: List.generate(
                  4,
                      (i) => DropdownMenuItem(value: i * 15, child: Text('${i * 15} min')),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedMinutes = value!;
                    _updateEndDate();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEndTimeLabel() {

    // Format it however you like; here's an example:
    String formattedEndTime = DateFormat('MMM d, yyyy HH:mm a').format(_endDate);

    return Text(
      'Ends at: $formattedEndTime',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildLocationDropdown({bool isReadOnly = false}) {
    return DropdownButtonFormField<Location?>(
      value: _selectedLocation,
      decoration: const InputDecoration(
        labelText: 'Select Location',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: Location.values.map((location) {
        return DropdownMenuItem<Location>(
          value: location,
          child: Text(location.displayName, overflow: TextOverflow.ellipsis,),
        );
      }).toList(),
      onChanged: isReadOnly
          ? null
          : (Location? newValue) {
        setState(() {
          _selectedLocation = newValue;
        });
      },
      validator: (Location? value) {
        if (value == null) {
          return 'Please select a location';
        }
        return null;
      },
    );
  }
}
