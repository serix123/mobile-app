import 'package:flutter/material.dart';

class SearchFields extends StatefulWidget {
  final void Function(String text) onSearch;
  const SearchFields({super.key, required this.onSearch});

  @override
  State<SearchFields> createState() => _SearchFieldsState();
}

class _SearchFieldsState extends State<SearchFields> {
  final TextEditingController _searchController = TextEditingController();

  void _resetFilters() {
    setState(() {
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        _buildButtonsRow(),
      ],
    );
  }

  Widget _buildButtonsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // ✅ Make it green
            foregroundColor: Colors.white, // ✅ White text
          ),
          onPressed: () {
            widget.onSearch(_searchController.text);
          },
          child: const Text('Search'),
        ),
        // OutlinedButton(
        //   style: OutlinedButton.styleFrom(
        //       foregroundColor: Colors.teal,
        //       side: const BorderSide(color: Colors.teal)),
        //   onPressed: _resetFilters,
        //   child: const Text('Reset'),
        // ),
      ],
    );
  }
}
