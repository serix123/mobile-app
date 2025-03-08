import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Utils {
  // Prevents the class from being instantiated or extended
  Utils._();

  // Static method for date formatting
  static String formatDate(DateTime date) {
    // Use any date formatting logic here, for simplicity let's return ISO8601
    return date.toIso8601String();
  }

  // Static method for custom logging
  static void log(String message) {
    // Customize your logging output format
    print("LOG: $message");
  }

  // Static method for email validation
  static bool isValidEmail(String email) {
    // Simple regex for email validation
    Pattern pattern = r'^\S+@\S+\.\S+$';
    RegExp regex = RegExp(pattern.toString());
    return regex.hasMatch(email);
  }

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.parse(value as String);
  }

  static DateTime combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static DateTime extractDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static TimeOfDay extractTimeOnly(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  static Future<String?> encodeFileToBase64(File? file) async {
    if (file == null) return null;

    try {
      List<int> fileBytes = await file.readAsBytes();
      String base64encode = base64Encode(fileBytes);
      return base64encode;
    } catch (e) {
      print("Error encoding file to base64: $e");
      return null;
    }
  }

  static MediaType determineMediaType(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      default:
        return MediaType(
            'application', 'octet-stream'); // Default or unknown file types
    }
  }

  static String formatEnumString(String enumValue) {
    return enumValue.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match m) => ' ${m.group(0)}',
    );
  }

  static Future<Uint8List?> downloadFile(String? url) async {
    if(url == null) {
      return null;
    }
    try {
      // Make an HTTP GET request to download the file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Convert the response body (bytes) to Uint8List
        return response.bodyBytes;
      } else {
        print('Failed to download file: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> downloadFileAndGetName(String url) async {
    try {
      // Make an HTTP GET request to download the file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Extract the file name from the URL
        String fileName = url.split('/').last;

        // Convert the response body (bytes) to Uint8List
        Uint8List fileBytes = response.bodyBytes;

        return {'fileName': fileName, 'fileBytes': fileBytes};
      } else {
        print('Failed to download file: ${response.statusCode}');
        return {'fileName': null, 'fileBytes': null};
      }
    } catch (e) {
      print('Error downloading file: $e');
      return {'fileName': null, 'fileBytes': null};
    }
  }
}

enum ListType { All, Personal, ImmediateHead, PersonInCharge, Admin }
