
import 'package:flutter/material.dart';

class GenericEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Widget? actionButton;

  const GenericEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.assignment_outlined,
    this.iconColor = Colors.blue,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 16),
              actionButton!,
            ]
          ],
        ),
      ),
    );
  }
}


class GenericErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final IconData icon;
  final Color iconColor;
  final String retryText;

  const GenericErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.retryText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: iconColor),
            const SizedBox(height: 16),
            Text(
              'Something Went Wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(retryText),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}