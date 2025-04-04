// Resource Type Dropdown
import 'package:flutter/material.dart';
import 'package:online_reservation/Features/CommunityResources/Data/Model/community_resources.model.dart';

class ResourceTypeDropdown extends StatefulWidget {
  final ValueChanged<ResourceType?> onChanged;

  const ResourceTypeDropdown({super.key, required this.onChanged});

  @override
  State<ResourceTypeDropdown> createState() => _ResourceTypeDropdownState();
}

class _ResourceTypeDropdownState extends State<ResourceTypeDropdown> {
  ResourceType? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category),
        suffixIcon: _selectedValue != null
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearSelection,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ResourceType>(
          value: _selectedValue,
          hint: const Text('Select resource type'),
          isExpanded: true,
          items: ResourceType.values.map((ResourceType type) {
            return DropdownMenuItem<ResourceType>(
              value: type,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(type.icon, color: Colors.grey[600]),
                title: Text(type.displayName),
              ),
            );
          }).toList(),
          onChanged: (ResourceType? newValue) {
            setState(() => _selectedValue = newValue);
            widget.onChanged(newValue);
          },
        ),
      ),
    );
  }

  void _clearSelection() {
    setState(() => _selectedValue = null);
    widget.onChanged(null);
  }
}

// Resource Status Dropdown
class ResourceStatusDropdown extends StatefulWidget {
  final ValueChanged<ResourceStatus?> onChanged;

  const ResourceStatusDropdown({super.key, required this.onChanged});

  @override
  State<ResourceStatusDropdown> createState() => _ResourceStatusDropdownState();
}

class _ResourceStatusDropdownState extends State<ResourceStatusDropdown> {
  ResourceStatus? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.library_add_check),
        suffixIcon: _selectedValue != null
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearSelection,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ResourceStatus>(
          value: _selectedValue,
          hint: const Text('Select status'),
          isExpanded: true,
          items: ResourceStatus.values.map((ResourceStatus status) {
            return DropdownMenuItem<ResourceStatus>(
              value: status,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(status.icon, color: status.color),
                title: Text(status.displayName),
              ),
            );
          }).toList(),
          onChanged: (ResourceStatus? newValue) {
            setState(() => _selectedValue = newValue);
            widget.onChanged(newValue);
          },
        ),
      ),
    );
  }

  void _clearSelection() {
    setState(() => _selectedValue = null);
    widget.onChanged(null);
  }
}