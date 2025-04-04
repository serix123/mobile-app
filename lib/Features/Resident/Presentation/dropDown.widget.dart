// widgets/role_filter_dropdown.dart
import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';

extension RoleTypeExtension on RoleType {
  String get displayName {
    switch (this) {
      case RoleType.ADMIN:
        return 'Admin';
      case RoleType.OFFICER:
        return 'Officer';
      case RoleType.RESIDENT:
        return 'Resident';
      case RoleType.ALL:
        return 'All';
    }
  }

  IconData get icon {
    switch (this) {
      case RoleType.ADMIN:
        return Icons.security;
      case RoleType.OFFICER:
        return Icons.badge;
      case RoleType.RESIDENT:
        return Icons.person;
      case RoleType.ALL:
        return Icons.people;
    }
  }
}

class RoleFilterDropdown extends StatefulWidget {
  final ValueChanged<RoleType?> onRoleChanged;

  const RoleFilterDropdown({
    super.key,
    required this.onRoleChanged,
  });

  @override
  State<RoleFilterDropdown> createState() => _RoleFilterDropdownState();
}

class _RoleFilterDropdownState extends State<RoleFilterDropdown> {
  RoleType? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 150;
        return InputDecorator(
          decoration: InputDecoration(
            prefixIcon: isMobile
                ? null
                : const Icon(
                    Icons.filter_alt_outlined,
                    size: 24,
                  ),
            suffixIcon: _selectedRole != null && _selectedRole != RoleType.ALL
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                    ),
                    iconSize: isMobile ? 12 : 24,
                    onPressed: _clearSelection,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RoleType>(
              value: _selectedRole,
              hint: Text('Filter by role', style: TextStyle(fontSize: isMobile ? 14 : 16)),
              isExpanded: true,
              items: RoleType.values.map((RoleType role) {
                return DropdownMenuItem<RoleType>(
                  value: role,
                  child: ListTile(
                    dense: isMobile,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      size: isMobile ? 12 : 24,
                      role.icon,
                      color: Colors.grey[600],
                    ),
                    title: Text(
                      role.displayName,
                      style: TextStyle(fontSize: isMobile ? 12 : 16),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (RoleType? newValue) {
                setState(() {
                  _selectedRole = newValue ?? RoleType.ALL;
                });
                widget.onRoleChanged(newValue == RoleType.ALL ? null : newValue);
              },
            ),
          ),
        );
      },
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedRole = null;
    });
    widget.onRoleChanged(null);
  }
}
