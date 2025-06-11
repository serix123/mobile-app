import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final bool hasNext;
  final bool hasPrevious;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  // final int currentPage;
  // final int totalPages;
  // final ValueChanged<int> onPageSelected;

  const PaginationControls({
    super.key,
    required this.hasNext,
    required this.hasPrevious,
    required this.onNext,
    required this.onPrevious,
    // required this.currentPage,
    // required this.totalPages,
    // required this.onPageSelected,
  });

  // List<Widget> _buildPageButtons() {
  //   // Optional: You can limit the number of visible page buttons
  //   const maxVisiblePages = 5;
  //   int startPage = (currentPage - (maxVisiblePages ~/ 2)).clamp(1, totalPages);
  //   int endPage = (startPage + maxVisiblePages - 1).clamp(1, totalPages);
  //
  //   // Adjust startPage if near the end
  //   if (endPage - startPage < maxVisiblePages - 1) {
  //     startPage = (endPage - maxVisiblePages + 1).clamp(1, totalPages);
  //   }

  //   return [
  //     for (int i = startPage; i <= endPage; i++)
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 4.0),
  //         child: OutlinedButton(
  //           style: OutlinedButton.styleFrom(
  //             backgroundColor: i == currentPage ? Colors.blue[100] : null,
  //           ),
  //           onPressed: () => onPageSelected(i),
  //           child: Text(i.toString()),
  //         ),
  //       ),
  //   ];
  // }

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