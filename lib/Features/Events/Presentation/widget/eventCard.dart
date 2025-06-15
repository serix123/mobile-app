import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: (event.imageUrl != null)
                ? ClipRRect(
              // Optional: Clip corners for a nicer look
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                event.imageUrl!,
                width: 150, // Take full width of the card
                height: 150, // Fixed height, adjust as needed
                fit: BoxFit
                    .contain, // Cover the area, cropping if necessary
                loadingBuilder: (BuildContext context,
                    Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                      loadingProgress.expectedTotalBytes !=
                          null
                          ? loadingProgress
                          .cumulativeBytesLoaded /
                          loadingProgress
                              .expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    alignment: Alignment.center,
                    height: 150,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image,
                        size: 50, color: Colors.grey),
                  );
                },
              ),
            )
                : Container(
              // Placeholder when no image URL
              alignment: Alignment.center,
              width: 150,
              height: 150,
              color: Colors.grey[
              350], // Light grey background for the icon
              child: const Icon(
                Icons.image, // The image icon
                size: 50, // Size of the icon
                color: Colors.grey, // Color of the icon
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event.isAttending)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(event.details),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(event.location),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(dateFormat.format(event.date)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Created by: ${event.creatorName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${event.attendeesCount} attending',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}