import 'package:flutter/material.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/medicalRecord.model.dart';
import 'package:online_reservation/config/app.color.dart';

class SearchFields extends StatefulWidget {
  final void Function(String text, String category) onSearch;
  const SearchFields({super.key, required this.onSearch});

  @override
  State<SearchFields> createState() => _SearchFieldsState();
}

class _SearchFieldsState extends State<SearchFields> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedDiagnosis;


  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedDiagnosis = null;
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
            backgroundColor: Colors.teal, // ✅ Make it green
            foregroundColor: Colors.white, // ✅ White text
          ),
          onPressed: () {
            widget.onSearch(
              _searchController.text,
              _selectedDiagnosis ?? "",
            );
          },
          child: const Text('Search'),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal,
              side: const BorderSide(color: Colors.teal)),
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
            value: _selectedDiagnosis,
            hint: const Text('Select Category'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: DiagnosisStatus.values.map((status) {
              final displayName = status.displayName;
              return DropdownMenuItem(
                value: status.jsonName,
                child: Text(displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDiagnosis = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
