import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.comment.model.dart';
import 'package:online_reservation/Utils/utils.dart';
import 'package:online_reservation/config/app.text.dart';

class CommentListWidget extends StatelessWidget {
  final List<Comment> comments;

  const CommentListWidget({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Text("No comments yet.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return ListTile(
          leading: const Icon(Icons.comment),
          title: Text(
            comment.userFullName ?? "Resident User",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(comment.comment,overflow: TextOverflow.ellipsis,),
          trailing: Text(Utils.formatCommentTimestamp(comment.createdAt ?? DateTime.now()),
            // "${comment.createdAt?.hour.toString().padLeft(2, '0')}:${comment.createdAt?.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
