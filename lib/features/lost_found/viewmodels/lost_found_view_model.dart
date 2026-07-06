import 'package:flutter/foundation.dart';

import '../data/lost_found_repository.dart';
import '../models/lost_found_models.dart';

class LostFoundViewModel extends ChangeNotifier {
  LostFoundViewModel({required this.repository}) {
    loadItems();
  }

  final LostFoundRepository repository;
  List<LostFoundItem> _items = [];
  bool _isLoading = false;
  String? _selectedItemId;
  String _query = '';
  ItemType? _typeFilter;
  ItemStatus? _statusFilter;

  List<LostFoundItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String get query => _query;
  ItemType? get typeFilter => _typeFilter;
  ItemStatus? get statusFilter => _statusFilter;

  LostFoundItem? get selectedItem {
    final selectedId = _selectedItemId;
    if (selectedId == null) {
      return null;
    }

    return itemById(selectedId);
  }

  List<LostFoundItem> get filteredItems {
    final normalizedQuery = _query.trim().toLowerCase();

    return _items.where((item) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          [
            item.title,
            item.id,
            item.location,
            item.description,
            item.reportedBy,
            item.category.label,
            item.status.label,
          ].any((value) => value.toLowerCase().contains(normalizedQuery));
      final matchesType = _typeFilter == null || item.type == _typeFilter;
      final matchesStatus =
          _statusFilter == null || item.status == _statusFilter;
      return matchesQuery && matchesType && matchesStatus;
    }).toList();
  }

  DashboardMetrics get metrics {
    final activeItems = _items
        .where((item) => item.status != ItemStatus.archived)
        .toList(growable: false);

    return DashboardMetrics(
      found: activeItems.where((item) => item.type == ItemType.found).length,
      lost: activeItems.where((item) => item.type == ItemType.lost).length,
      pendingClaims: _items
          .where(
            (item) =>
                item.status == ItemStatus.claimReview ||
                item.claim?.status == ClaimStatus.waiting,
          )
          .length,
      resolved: _items
          .where((item) => item.status == ItemStatus.returned)
          .length,
    );
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await repository.loadItems();
      _syncSelection();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading items: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  LostFoundItem? itemById(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  void setQuery(String value) {
    _query = value;
    _syncSelection();
    notifyListeners();
  }

  void setTypeFilter(ItemType? type) {
    _typeFilter = type;
    _syncSelection();
    notifyListeners();
  }

  void setStatusFilter(ItemStatus? status) {
    _statusFilter = status;
    _syncSelection();
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _typeFilter = null;
    _statusFilter = null;
    _syncSelection();
    notifyListeners();
  }

  void selectItem(LostFoundItem item) {
    _selectedItemId = item.id;
    notifyListeners();
  }

  Future<LostFoundItem?> changeStatus(String itemId, ItemStatus status) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await repository.changeStatus(itemId, status);
      if (updated != null) {
        _items = [
          for (final current in _items)
            if (current.id == updated.id) updated else current,
        ];
        _selectedItemId = updated.id;
        _syncSelection();
        return updated;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error changing status: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<LostFoundItem?> addReport(ReportDraft draft) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await repository.addReport(draft);
      _items = [created, ..._items];
      _selectedItemId = created.id;
      _query = '';
      _statusFilter = null;
      _syncSelection();
      return created;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding report: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<LostFoundItem?> updateReport(String id, ReportDraft draft) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await repository.updateReport(id, draft);
      if (updated != null) {
        _items = [
          for (final current in _items)
            if (current.id == updated.id) updated else current,
        ];
        _selectedItemId = updated.id;
        _syncSelection();
        return updated;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating report: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> deleteReport(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.deleteReport(id);
      _items = [for (final item in _items) if (item.id != id) item];
      if (_selectedItemId == id) {
        _selectedItemId = null;
      }
      _syncSelection();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting report: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _syncSelection() {
    final filtered = filteredItems;
    if (filtered.isEmpty) {
      _selectedItemId = null;
      return;
    }

    final selectedId = _selectedItemId;
    if (selectedId == null || !filtered.any((item) => item.id == selectedId)) {
      _selectedItemId = filtered.first.id;
    }
  }
}
