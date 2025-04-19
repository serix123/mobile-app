import 'package:flutter/material.dart';

abstract class RepositoryProvider<T> with ChangeNotifier {
  @protected
  final _apiService;
  @protected
  List<T> _data = [];
  @protected
  bool _isLoading = false;
  @protected
  String? _error;

  RepositoryProvider(this._apiService);

  List<T> get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
}