import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/Features/Events/Domain/event.repository.dart';

class EventViewScreen extends StatelessWidget {
  static const String screenId = "/eventItem";
  static const String title = "Event";
  final Event event;

  const EventViewScreen({super.key, required this.event});

  void _handlePostEdit(BuildContext context) async {
    final result = await Navigator.pushNamed(
        context, RouteGenerator.eventEditScreen,
        arguments: event);

    if (result != null) {
      final provider = context.read<EventProvider>();
      await provider.getEvents();
    }
  }

  void _handleAttending(BuildContext context, bool isAttending) async {
    final provider = context.read<EventProvider>();

    if (isAttending) {
      await provider.attendEvent(event.id);
    } else {
      await provider.unattendEvent(event.id);
    }
    if (provider.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${provider.error}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted successfully!')));
      Navigator.pop(context, event);
    }
  }

  Future<void> _handleDeleteEvent(BuildContext context) async {
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
        await provider.deleteEvent(event.id);
        if (provider.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: ${provider.error}')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully')),
          );
          Navigator.pop(context, event);
        }


    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<ProfileProvider>().user!.id;
    return ResponsiveLayout(
      mobileBody: body(context),
      desktopBody: body(context),
      title: const Text(EventViewScreen.title),
      actions: [
        if (event.creatorId == userId)
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _handlePostEdit(context)),
      ],
    );
  }

  Widget body(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y • h:mm a');
    final createdFormat = DateFormat('MMM d, y');
    return Consumer2<EventProvider, ProfileProvider>(
      builder: (context, provider, profileProvider, child) {
        final userId = profileProvider.user!.id;
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                event.details,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                icon: Icons.location_on,
                label: 'Location',
                value: event.location,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                icon: Icons.calendar_today,
                label: 'Date & Time',
                value: dateFormat.format(event.date),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                icon: Icons.person,
                label: 'Organizer',
                value: event.creatorName,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                icon: Icons.people,
                label: 'Attendees',
                value: '${event.attendeesCount} people attending',
              ),
              const SizedBox(height: 24),
              if (event.creatorId != userId)
              ...[
                if (event.isAttending)
                  ElevatedButton(
                    onPressed: () {
                      // Handle cancel attendance
                      _handleAttending(context,false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Cancel Attendance'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      // Handle attend event
                      _handleAttending(context,true);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Attend Event'),
                  ),
              ]
              else
              ElevatedButton(
                onPressed: () {
                  // Handle cancel attendance
                  _handleDeleteEvent(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Delete Event'),
              ),
              const SizedBox(height: 16),
              Text(
                'Created on ${createdFormat.format(event.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
