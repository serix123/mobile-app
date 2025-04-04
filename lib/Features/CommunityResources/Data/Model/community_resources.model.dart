// models/community_resource.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Users/Data/Model/user.model.dart';
import 'package:flutter/material.dart';

enum ResourceType { FOOD, MED, SHELTER, TOOL, EDU, OTHER }

enum ResourceStatus { AVAILABLE, IN_USE, MAINTENANCE, UNAVAILABLE }

extension ResourceTypeExtension on ResourceType {
  String get displayName {
    switch (this) {
      case ResourceType.FOOD:
        return 'FOOD';
      case ResourceType.MED:
        return 'MED';
      case ResourceType.SHELTER:
        return 'SHELTER';
      case ResourceType.TOOL:
        return 'TOOL';
      case ResourceType.EDU:
        return 'EDU';
      case ResourceType.OTHER:
        return 'OTHER ';
    }
  }

  IconData get icon {
    switch (this) {
      case ResourceType.FOOD: return Icons.restaurant;
      case ResourceType.MED: return Icons.local_hospital;
      case ResourceType.SHELTER: return Icons.home_work;
      case ResourceType.TOOL: return Icons.build;
      case ResourceType.EDU: return Icons.school;
      case ResourceType.OTHER: return Icons.widgets;
    }
  }
}

extension ResourceStatusExtension on ResourceStatus {
  String get displayName {
    switch (this) {
      case ResourceStatus.AVAILABLE:
        return 'AVAILABLE';
      case ResourceStatus.IN_USE:
        return 'IN_USE';
      case ResourceStatus.MAINTENANCE:
        return 'MAINTENANCE';
      case ResourceStatus.UNAVAILABLE:
        return 'UNAVAILABLE';
    }
  }

  Color get color {
    switch (this) {
      case ResourceStatus.AVAILABLE:
        return Colors.green ;
      case ResourceStatus.IN_USE:
        return Colors.orange;
      case ResourceStatus.MAINTENANCE:
        return Colors.grey;
      case ResourceStatus.UNAVAILABLE:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case ResourceStatus.AVAILABLE:
        return Icons.check_circle;
      case ResourceStatus.IN_USE:
        return Icons.access_time_filled;
      case ResourceStatus.MAINTENANCE:
        return Icons.home_repair_service;
      case ResourceStatus.UNAVAILABLE:
        return Icons.not_interested;
    }
  }
}

class Resource {
  final int? id;
  final String name;
  final String description;
  final String contactInfo;
  final ResourceType resourceType;
  final ResourceStatus status;
  final User? manageBy;

  Resource({
    this.id,
    required this.name,
    required this.description,
    required this.contactInfo,
    required this.resourceType,
    required this.status,
    this.manageBy,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      contactInfo: json['contact_info'],
      resourceType: _parseResourceType(json['resource_type']),
      status: _parseResourceStatus(json['status']),
      manageBy: User.fromJson(json['managed_by']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'contact_info': contactInfo,
      'resource_type': resourceType.displayName,
      'status': status.displayName,
    };
  }

  Resource copyWith(Resource resource) {
    return resource;
  }

  static ResourceType _parseResourceType(String type) {
    switch (type.toUpperCase()) {
      case 'FOOD':
        return ResourceType.FOOD;
      case 'MED':
        return ResourceType.MED;
      case 'SHELTER':
        return ResourceType.SHELTER;
      case 'TOOL':
        return ResourceType.TOOL;
      case 'EDU':
        return ResourceType.EDU;
      default:
        return ResourceType.OTHER;
    }
  }

  static ResourceStatus _parseResourceStatus(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return ResourceStatus.AVAILABLE;
      case 'IN_USE':
        return ResourceStatus.IN_USE;
      case 'MAINTENANCE':
        return ResourceStatus.MAINTENANCE;
      default:
        return ResourceStatus.UNAVAILABLE;
    }
  }
}
