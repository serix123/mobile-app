
import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/Features/Events/Data/Service/event.service.dart';

class EventProvider with ChangeNotifier{
  final EventApiService _apiService;

  PaginatedResults<Event>? _paginatedEvents;
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  EventProvider(this._apiService);

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedEvents?.next != null;
  bool get hasPrevious => _paginatedEvents?.previous != null;

  Future<void> getEvents(
      {int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedEvents = await _apiService.getEvents(
          page: page, query: query);
      _events = _paginatedEvents?.results ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getEvent(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final event = await _apiService.getEvent(id);
      final index = _events.indexWhere((v) => v.id == event.id);
      _events[index] = _events[index].copyWith(
        id : event.id,
        name: event.name,
        attendeesCount: event.attendeesCount,
        details: event.details,
        date: event.date,
        location: event.location,
        isAttending: event.isAttending,
        creatorName: event.creatorName,
        creatorId: event.creatorId,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newEvent = await _apiService.updateEvent(event: event);
      final index = _events.indexWhere((v) => v.id == event.id);
      _events[index] = _events[index].copyWith(
        id : newEvent.id,
        name: newEvent.name,
        attendeesCount: newEvent.attendeesCount,
        details: newEvent.details,
        date: newEvent.date,
        location: newEvent.location,
        isAttending: newEvent.isAttending,
        creatorName: newEvent.creatorName,
        creatorId: newEvent.creatorId,
        createdAt: newEvent.createdAt,
        updatedAt: newEvent.updatedAt,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.createEvent(event: event);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteEvent(int eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteEvent(eventId);
      if (success) {
        _events.removeWhere((event) => event.id == eventId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> attendEvent(int eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newEvent = await _apiService.attendEvent(eventId);
      final index = _events.indexWhere((v) => v.id == newEvent.id);
      _events[index] = _events[index].copyWith(
        id : newEvent.id,
        name: newEvent.name,
        attendeesCount: newEvent.attendeesCount,
        details: newEvent.details,
        date: newEvent.date,
        location: newEvent.location,
        isAttending: newEvent.isAttending,
        creatorName: newEvent.creatorName,
        creatorId: newEvent.creatorId,
        createdAt: newEvent.createdAt,
        updatedAt: newEvent.updatedAt,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> unattendEvent(int eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newEvent = await _apiService.unattendEvent(eventId);
      final index = _events.indexWhere((v) => v.id == newEvent.id);
      _events[index] = _events[index].copyWith(
        id : newEvent.id,
        name: newEvent.name,
        attendeesCount: newEvent.attendeesCount,
        details: newEvent.details,
        date: newEvent.date,
        location: newEvent.location,
        isAttending: newEvent.isAttending,
        creatorName: newEvent.creatorName,
        creatorId: newEvent.creatorId,
        createdAt: newEvent.createdAt,
        updatedAt: newEvent.updatedAt,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }


  Future<void> loadNextPage() async {
    if (hasNext) {
      final nextPage = _getPageFromUrl(_paginatedEvents!.next!);
      await getEvents(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedEvents!.previous!);
      await getEvents(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }

}