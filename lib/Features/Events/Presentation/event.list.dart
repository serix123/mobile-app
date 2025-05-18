import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/paginationControls.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/Features/Events/Domain/event.repository.dart';
import 'package:online_reservation/Features/Events/Presentation/widget/event.search.dart';
import 'package:online_reservation/Features/Events/Presentation/widget/eventCard.dart';
import 'package:provider/provider.dart';

class EventListScreen extends StatefulWidget {
  static const String screenId = "/eventsList";
  static const String title = "Events List";
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().getEvents();
    });
  }

  void _handlePostCreate() async {
    final result =
        await Navigator.pushNamed(context, RouteGenerator.eventEditScreen);

    if (result != null) {
      final provider = context.read<EventProvider>();
      await provider.getEvents();
    }
  }

  void _handlepostEdit(Event event) async {
    final result = await Navigator.pushNamed(
        context, RouteGenerator.eventViewScreen,
        arguments: event);

    if (result != null) {
      final provider = context.read<EventProvider>();
      await provider.getEvents();
    }
  }

  Future<void> _handleDeleteEvent(BuildContext context, int eventId) async {
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
      try {
        await context.read<EventProvider>().deleteEvent(eventId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
        await context.read<EventProvider>().getEvents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _handleAttendEvent(BuildContext context, int eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Attend'),
        content: const Text('Are you sure you want to attend this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Attend'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<EventProvider>().attendEvent(eventId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully')),
        );
        await context.read<EventProvider>().getEvents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attend failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _mobileBody(),
      desktopBody: _mobileBody(),
      title: const Text(EventListScreen.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _handlePostCreate(),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Consumer<EventProvider>(
        builder: (context, provider, child) {
          return SearchFields(
            onSearch: (text) {
              provider.getEvents(query: text);
            },
          );
        },
      ),
    );
  }

  Widget _mobileBody() {
    return Column(
      children: [
        _searchBar(),
        _paginationControls(),
        Expanded(
          child: Consumer<EventProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) return _buildErrorState(provider);
              if (provider.events.isEmpty) {
                return _buildEmptyState(provider);
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.events.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = provider.events[index];
                  return InkWell(
                    child: EventCard(event: event),
                    onTap: () => _handlepostEdit(event),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _paginationControls() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        return PaginationControls(
            hasNext: provider.hasNext,
            hasPrevious: provider.hasPrevious,
            onNext: provider.loadNextPage,
            onPrevious: provider.loadPreviousPage);
      },
    );
  }

  Widget _buildErrorState(EventProvider provider) {
    return GenericErrorState(
        errorMessage: provider.error ?? "Cannot retrieve medical events",
        onRetry: () async => await provider.getEvents());
  }

  Widget _buildEmptyState(EventProvider provider) {
    return GenericEmptyState(
      title: 'No Records Found.',
      description: 'When new events are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () => provider.getEvents(),
        child: const Text('Reload'),
      ),
    );
  }
}
