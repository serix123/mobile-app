import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:provider/provider.dart';

class SearchFields extends StatefulWidget {
  final void Function(String text, String status, String priority) onSearch;
  const SearchFields({super.key, required this.onSearch});

  @override
  State<SearchFields> createState() => _SearchFieldsState();
}

class _SearchFieldsState extends State<SearchFields> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPriority;


  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedPriority = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
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
            _buildDropdownRow(),
            const SizedBox(height: 10),
            _buildButtonsRow(),
          ],
        );
      },
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
            widget.onSearch(
              _searchController.text,
              _selectedStatus ?? "",
              _selectedPriority ?? "",
            );
          },
          child: const Text('Search'),
        ),
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
    final isOfficer = context.read<ProfileProvider>().user?.isOfficer ?? false;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            hint: const Text('Select status'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: isOfficer ?
            IssueStatus.values.where((status) => status != IssueStatus.DRAFT).map((status) {
              final displayName = status.displayName;
              return DropdownMenuItem(
                value: status.jsonName,
                child: Text(displayName),
              );
            }).toList()
            :IssueStatus.values.map((status) {
              final displayName = status.displayName;
              return DropdownMenuItem(
                value: status.jsonName,
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
        const SizedBox(width: 20),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedPriority,
            hint: const Text('Select status'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: IssuePriority.values.map((priority) {
              final displayName = priority.displayName;
              return DropdownMenuItem(
                value: priority.jsonName,
                child: Text(displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPriority = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
