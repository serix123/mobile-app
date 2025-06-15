import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Users/Data/Model/user.model.dart';
import 'package:online_reservation/Features/Users/Domain/user.repository.dart';
import 'package:online_reservation/Features/Users/Presentation/user.view.dart';
import 'package:provider/provider.dart';

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
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //   decoration: BoxDecoration(
            //     color: _getRoleColor(context, user.role),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Text(user.role, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white)),
            // ),
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text('Edit User'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete User'),
                  ),
                ),
              ],
              onSelected: (String value) {
                switch (value) {
                  case 'edit':
                    _handleEditUser(context, user);
                    break;
                  case 'delete':
                    _handleDeleteUser(context, user.id);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Add these handler methods
  void _handleEditUser(BuildContext context, User user) async {
        Navigator.of(context)
            .pushNamed(RouteGenerator.userScreen, arguments: UserScreenConfig(user: user));
    // Navigate to edit screen
    // Navigator.of(context)
    //     .pushNamed(RouteGenerator.userScreen, arguments: UserScreenConfig(user: user, resident: resident));
  }

  void _handleDeleteUser(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<UserProvider>(
            builder: (context, provider, child) => TextButton(
              onPressed: () async {
                await provider.deleteUser(userId).then((_) => Navigator.pop(context));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ),
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
