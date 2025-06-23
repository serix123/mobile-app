import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Features/Notice/Data/Model/notice.model.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:provider/provider.dart';

class NoticeListItem extends StatelessWidget {
  final Notice notice;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoticeListItem({
    super.key,
    required this.notice,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _buildListItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final isOfficer = profileProvider.user!.isOfficer;
        return Card(
          child: Stack(
            children: [
              InkWell(
                onTap: onTap,
                child: Row(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final imageSize = (constraints.maxWidth * 0.3).clamp(80.0, 150.0);
                        return ConstrainedBox(constraints: BoxConstraints(
                          maxWidth: imageSize,
                          maxHeight: imageSize,
                        ),child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (notice.imageUrl != null)
                              ? ClipRRect(
                            // Optional: Clip corners for a nicer look
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              notice.imageUrl!,
                              width: double.infinity,
                              height: double.infinity, // Fixed height, adjust as needed
                              fit: BoxFit
                                  .contain, // Cover the area, cropping if necessary
                            ),
                          )
                              : Container(
                            // Placeholder when no image URL
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors
                                .grey[350], // Light grey background for the icon
                            child: const Icon(
                              Icons.image, // The image icon
                              size: 50, // Size of the icon
                              color: Colors.grey, // Color of the icon
                            ),
                          ),
                        ),);
                      },
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Title Text Widget ---
                            Text(
                              notice.title,
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold, // Make the title bold
                                color:
                                Colors.deepPurple, // A nice color for the title
                              ),
                              maxLines: 1, // Limit title to 2 lines
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis if it overflows
                            ),
                            const SizedBox(
                                height: 8.0), // Space between title and date

                            // --- Created Date Text Widget ---
                            Text(
                              // Format the DateTime into a readable string
                              'Created: ${DateFormat('MMM d, yyyy · h:mm a').format(notice.createdDate ?? DateTime.now())}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600], // Softer color for date
                                fontStyle: FontStyle
                                    .italic, // Italicize date for distinction
                              ),

                            ),
                            const SizedBox(
                                height: 16.0), // Space between date and details

                            // --- Details Paragraph Text Widget ---
                            Text(
                              notice.details ?? "",
                              style: const TextStyle(
                                fontSize: 16.0,
                                height: 1.5, // Line height for better readability
                                color: Colors.black87, // Slightly softer black
                              ),
                                maxLines: 4, // Limit title to 2 lines
                                overflow: TextOverflow.ellipsis
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isOfficer)
              Positioned(
                right: 0,
                top: 0,
                child: PopupMenuButton<String>(

                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => [
                    if(onEdit != null)
                      PopupMenuItem<String>(
                        onTap: onEdit,
                        value: 'edit',
                        child: const ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('Edit'),
                        ),
                      ),
                    if(onDelete != null)
                      PopupMenuItem<String>(
                        onTap: onDelete,
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete'),
                        ),
                      ),
                  ],
                  // onSelected: (String value) {
                  //   if (value == 'edit') onEdit() ?? null;
                  //   if (value == 'delete') onDelete();
                  // },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
