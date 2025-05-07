import 'package:flutter/material.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/config/app.color.dart';

class SearchFields extends StatefulWidget {
  final void Function(String text, String status, String gender) onSearch;
  const SearchFields({super.key, required this.onSearch});

  @override
  State<SearchFields> createState() => _SearchFieldsState();
}

class _SearchFieldsState extends State<SearchFields> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedGender;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedGender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        _buildDropdownRow(),
        const SizedBox(height: 10),
        _buildButtonsRow(),
      ],
    );
  }

  Widget _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(

          style: ElevatedButton.styleFrom(
            backgroundColor: kGreenNormal, // ✅ Make it green
            foregroundColor: Colors.white, // ✅ White text
          ),
          onPressed: () {
            widget.onSearch(
              _searchController.text,
              _selectedStatus ?? "",
              _selectedGender ?? "",
            );
          },
          child: const Text('Search'),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              foregroundColor: kGreenNormal,
              side: const BorderSide(color: kGreenNormal)),
          onPressed: _resetFilters,
          child: const Text('Reset'),
        ),
      ],
    );
  }

  Widget _buildDropdownRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            hint: const Text('Select Status'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: ApplicationStatus.values.map((status) {
              final displayName = status.displayName;
              return DropdownMenuItem(
                value: displayName,
                child: Text(displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            hint: const Text('Select Gender'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: Gender.values.map((gender) {
              final genderName = gender.displayName;
              return DropdownMenuItem(
                value: genderName,
                child: Text(genderName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
