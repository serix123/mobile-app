import 'package:flutter/material.dart';

class SearchFields extends StatefulWidget {
  final void Function(String text, DateTime? startDate, DateTime? endDate) onSearch;

  const SearchFields({super.key, required this.onSearch});

  @override
  State<SearchFields> createState() => _SearchFieldsState();
}

class _SearchFieldsState extends State<SearchFields> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
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
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(_startDate != null
                    ? 'Start: ${_formatDate(_startDate!)}'
                    : 'Select Start Date'),
                onPressed: _pickStartDate,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(_endDate != null
                    ? 'End: ${_formatDate(_endDate!)}'
                    : 'Select End Date'),
                onPressed: _pickEndDate,
              ),
            ),
          ],
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
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            widget.onSearch(
              _searchController.text,
              _startDate,
              _endDate,
            );
          },
          child: const Text('Search'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.teal,
            side: const BorderSide(color: Colors.teal),
          ),
          onPressed: _resetFilters,
          child: const Text('Reset'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

