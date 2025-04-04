// widgets/search_field.dart
import 'dart:async';

import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final Duration debounceDuration;

  const SearchField({
    super.key,
    required this.onSearchChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearchChanged(query.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 300;
        return TextField(
          style: TextStyle(fontSize: isMobile ? 14 : 16),
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search ...',
            prefixIcon: Icon(Icons.search,size: isMobile ? 12 : 24,),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear,size: isMobile ? 12 : 24,),
              onPressed: () {
                _searchController.clear();
                widget.onSearchChanged('');
              },
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: _onSearchChanged,
        );
      },
    );
  }
}