

import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/Utils/utils.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onAttend;
  final VoidCallback onDelete;

  const EventListItem({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onAttend,
    required this.onDelete,
  });


  @override
  Widget build(BuildContext context) {
    return _buildListItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          InkWell(
            onTap: () {},
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Title', event.name),
                        _buildInfoRow('Details', event.details),

                        // _buildInfoRow('Treatment', event.treatments ?? ""),
                        _buildInfoRow('Location', event.location ?? ""),
                        _buildInfoRow('Date', Utils.formatDateISO(event.date)),
                        _buildInfoRow('Attending', "${event.attendeesCount}"),
                        const SizedBox(height: 8),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text('Edit'),
                  ),
                ),
                if(!event.isAttending)
                const PopupMenuItem<String>(
                  value: 'attend',
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Attend'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                  ),
                ),
              ],
              onSelected: (String value) {
                if (value == 'edit') onEdit();
                if (value == 'attend') onAttend();
                if (value == 'delete') onDelete();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis ,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getRoleColor(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'super admin':
        return Colors.red.shade700;
      case 'staff':
        return Theme.of(context).primaryColor;
      default:
        return Colors.grey.shade600;
    }
  }
}