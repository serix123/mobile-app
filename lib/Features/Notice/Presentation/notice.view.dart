import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Notice/Data/Model/notice.model.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeViewScreen extends StatelessWidget {
  static const String screenId = "/noticeItem";
  static const String title = "Notice";
  final Notice notice;
  const NoticeViewScreen({super.key, required this.notice});

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

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _mobileBody(),
      desktopBody: _desktopBody(),
      title: const Text(title),
    );
  }

  Widget _mobileBody() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          _imageBuilder(),
          const SizedBox(
            height: 24,
          ),
          _bodyContent(),
        ],
      ),
    );
  }

  Widget _desktopBody() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageBuilder(),
          const SizedBox(
            width: 24,
          ),
          _bodyContent(),
        ],
      ),
    );
  }

  Widget _bodyContent() {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title Text Widget ---
          Text(
            notice.title,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold, // Make the title bold
              color: Colors.deepPurple, // A nice color for the title
            ),
            maxLines: 1, // Limit title to 2 lines
            overflow: TextOverflow.ellipsis, // Add ellipsis if it overflows
          ),
          const SizedBox(height: 8.0), // Space between title and date
          Text(
            // Format the DateTime into a readable string
            'Created: ${DateFormat('MMM d, yyyy · h:mm a').format(notice.createdDate ?? DateTime.now())}',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[600], // Softer color for date
              fontStyle: FontStyle.italic, // Italicize date for distinction
            ),
          ),
          const SizedBox(height: 16.0), // Space between date and details
          // --- Details Paragraph Text Widget ---
          // --- Created Date Text Widget ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    notice.details ?? "",
                    style: const TextStyle(
                      fontSize: 16.0,
                      height: 1.5, // Line height for better readability
                      color: Colors.black87, // Slightly softer black
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageBuilder() {
    return Expanded(
      flex: 1,
      child: notice.imageUrl != null
          ? Container(
              // Optional: A container for background color or padding around the image
              color: Colors.grey[200], // Background color to see the boundaries
              child: InkWell(
                onTap: () => _openDocument(notice.imageUrl!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    notice.imageUrl!,
                    fit: BoxFit.cover, // Fills the box, cropping if necessary
                  ),
                ),
              ),
            )
          : Container(
              // Placeholder when no image URL
              alignment: Alignment.center,
              color: Colors.grey[350], // Light grey background for the icon
              child: const Icon(
                Icons.image,
                color: Colors.grey, // Color of the icon
              ),
            ),
    );
  }
}
