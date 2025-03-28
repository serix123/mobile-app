// screens/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/paginationControls.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Users/Domain/user.repository.dart';
import 'package:online_reservation/Features/Users/Presentation/listItem.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatelessWidget {
  static const String screenId = "/users";
  static const String title = "user list";
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).getUsers();
    return ResponsiveLayout(
      desktopBody: body(),
      mobileBody: body(),
      title: title,
      currentRoute: screenId,
    );
  }

  Column body() {
    return Column(
      children: [
        Expanded(
          child: Consumer<UserProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return GenericErrorState(
                  errorMessage: provider.error!,
                  onRetry: () => provider.getUsers(),
                );
              }

              if (provider.users.isEmpty) {
                return const GenericEmptyState(
                  title: 'No Users Found',
                  description: 'No users are currently registered in the system',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = provider.users[index];
                  return UserListItem(user: user);
                },
              );
            },
          ),
        ),
        Consumer<UserProvider>(
          builder: (context, provider, _) {
            return PaginationControls(
              hasNext: provider.hasNext,
              hasPrevious: provider.hasPrevious,
              onNext: provider.loadNextPage,
              onPrevious: provider.loadPreviousPage,
            );
          },
        )
      ],
    );
  }
}
