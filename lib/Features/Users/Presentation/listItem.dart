// widgets/user_list_item.dart
import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Users/Data/Model/user.model.dart';

class UserListItem extends StatelessWidget {
  final User user;

  const UserListItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(user.firstName[0], style: const TextStyle(color: Colors.white)),
        ),
        title: Text(user.fullName),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(context, user.role),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(user.role, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.more_vert),
          ],
        ),
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
