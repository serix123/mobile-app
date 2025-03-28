import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final bool hasNext;
  final bool hasPrevious;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PaginationControls({
    super.key,
    required this.hasNext,
    required this.hasPrevious,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasPrevious)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
                onPressed: onPrevious,
              ),
            ),
          if (hasNext)
            OutlinedButton.icon(
              icon: const Icon(Icons.chevron_right),
              label: const Text('Next'),
              onPressed: onNext,
            ),
        ],
      ),
    );
  }
}