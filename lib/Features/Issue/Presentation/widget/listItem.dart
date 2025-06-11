import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:provider/provider.dart';

class IssueListItem extends StatelessWidget {
  final Issue issue;
  final VoidCallback onTap;
  // final VoidCallback onResolve;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  // final Function(String) onStatusChanged;

  const IssueListItem({
    super.key,
    required this.issue,
    // required this.onResolve,
    this.onEdit,
    this.onDelete,
    required this.onTap,
    // required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return buildItemList();
  }

  Widget buildItemList() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final isSuperUser = profileProvider.user!.isSuperuser;
        return Card(
          child: Stack(
            children: [
              InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (issue.imageUrl != null)
                            ? ClipRRect(
                                // Optional: Clip corners for a nicer look
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  issue.imageUrl!,
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
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Title', issue.title),
                              _buildInfoRow('Description', issue.description),
                              if (issue.userFullName != null)
                                _buildInfoRow('Author', issue.userFullName!),
                              if (issue.reportedDate != null)
                                _buildInfoRow('Date reported',
                                    _formatDate(issue.reportedDate!)),
                              if (issue.resolvedDate != null)
                                _buildInfoRow('Date resolved',
                                    _formatDate(issue.resolvedDate!)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: issue.priority.color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          issue.priority.displayName.toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: issue.status.color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          issue.status.displayName.toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSuperUser)
                Positioned(
                  right: 0,
                  top: 0,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (BuildContext context) => [
                      // if (issue.resolvedDate == null)
                      //   const PopupMenuItem<String>(
                      //     value: 'resolve',
                      //     child: ListTile(
                      //       leading: Icon(Icons.check_box, color: Colors.green),
                      //       title: Text('Resolve'),
                      //     ),
                      //   ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('Edit'),
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
                      // if (value == 'resolve') onResolve();
                      if (value == 'edit') onEdit != null ? onEdit!() : () {};
                      if (value == 'delete')
                        onDelete != null ? onDelete!() : () {};
                    },
                  ),
                )
              // else if (issue.status != IssueStatus.RESOLVED)
              //   Positioned(
              //     right: 0,
              //     top: 0,
              //     child: PopupMenuButton<String>(
              //       icon: const Icon(Icons.more_vert),
              //       itemBuilder: (BuildContext context) => [
              //         if (issue.status == IssueStatus.OPEN)
              //           const PopupMenuItem<String>(
              //             value: 'resolve',
              //             child: ListTile(
              //               leading: Icon(Icons.check_box, color: Colors.green),
              //               title: Text('Resolve'),
              //             ),
              //           ),
              //         // const PopupMenuItem<String>(
              //         //   value: 'edit',
              //         //   child: ListTile(
              //         //     leading: Icon(Icons.edit, color: Colors.blue),
              //         //     title: Text('Edit'),
              //         //   ),
              //         // ),
              //         // const PopupMenuItem<String>(
              //         //   value: 'delete',
              //         //   child: ListTile(
              //         //     leading: Icon(Icons.delete, color: Colors.red),
              //         //     title: Text('Delete'),
              //         //   ),
              //         // ),
              //       ],
              //       onSelected: (String value) {
              //         // if (value == 'resolve') onResolve();
              //         if (value == 'edit') onEdit != null ? onEdit!() : () {};
              //         if (value == 'delete')
              //           onDelete != null ? onDelete!() : () {};
              //       },
              //     ),
              //   )
            ],
          ),
        );
      },
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
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    const statusOptions = {
      'open': 'Open',
      'resolved': 'Resolved',
    };

    return DropdownButtonFormField<String>(
      value: issue.status.displayName,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: statusOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {},
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }
}
