// event_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/Features/Events/Domain/event.repository.dart';
import 'package:provider/provider.dart';

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
  late final TextEditingController _locationController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _nameController = TextEditingController(text: event?.name ?? '');
    _detailsController = TextEditingController(text: event?.details ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _selectedDate = event?.date ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(event?.date ?? DateTime.now());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() async {
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

      final event = Event(
        id: widget.event?.id ?? 0,
        name: _nameController.text,
        date: eventDate,
        details: _detailsController.text,
        location: _locationController.text,
        creatorId: widget.event?.creatorId ?? 1, // Get from auth
        creatorName: widget.event?.creatorName ?? 'Current User',
        attendeesCount: widget.event?.attendeesCount ?? 0,
        isAttending: widget.event?.isAttending ?? false,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        attendeesList: widget.event?.attendeesList ?? []
      );
      final provider = context.read<EventProvider>();
      try {
        if (widget.event != null) {
          await provider.updateEvent(event);
        } else {
          await provider.createEvent(event);
        }
        print("error : ${provider.error}");
        if (provider.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${provider.error}')));
          }
        }else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Submitted successfully!')));
            Navigator.pop(context, event);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
          // Navigator.pop(context);
        }
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
              // Handle delete
              Navigator.pop(context, 'delete');
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
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event location';
                    }
                    return null;
                  },
                ),
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
                              Text(DateFormat('MMM d, y').format(_selectedDate)),
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
                              Text(_selectedTime.format(context)),
                              const Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child:
                  Text(widget.event == null ? 'Create Event' : 'Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
