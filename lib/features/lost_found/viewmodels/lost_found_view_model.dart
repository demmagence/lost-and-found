import 'package:flutter/foundation.dart';

import '../data/lost_found_repository.dart';
import '../models/lost_found_models.dart';

class LostFoundViewModel extends ChangeNotifier {
  LostFoundViewModel({required this.repository}) {
    _items = repository.loadItems();
    _selectedItemId = _items.isEmpty ? null : _items.first.id;
    _nextIdNumber = _resolveNextIdNumber(_items);
  }

  final LostFoundRepository repository;
  late List<LostFoundItem> _items;
  late int _nextIdNumber;
  String? _selectedItemId;
  String _query = '';
  ItemType? _typeFilter;
  ItemStatus? _statusFilter;

  List<LostFoundItem> get items => List.unmodifiable(_items);
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

  LostFoundItem? changeStatus(String itemId, ItemStatus status) {
    final item = itemById(itemId);
    if (item == null) {
      return null;
    }

    final updated = item.copyWith(
      status: status,
      activities: [
        ActivityLog(
          message: 'Status diubah menjadi ${status.label}',
          actor: 'Staff Lost and Found',
          timestamp: DateTime.now(),
        ),
        ...item.activities,
      ],
    );

    _items = [
      for (final current in _items)
        if (current.id == item.id) updated else current,
    ];
    _selectedItemId = updated.id;
    _syncSelection();
    notifyListeners();

    return updated;
  }

  LostFoundItem addReport(ReportDraft draft) {
    final created = LostFoundItem(
      id: 'LF-${_nextIdNumber++}',
      title: draft.title,
      type: draft.type,
      category: draft.category,
      location: draft.location,
      description: draft.description,
      reportedBy: draft.reportedBy,
      contact: draft.contact,
      reportedAt: DateTime.now(),
      status: ItemStatus.open,
      priority: draft.priority,
      activities: [
        ActivityLog(
          message: 'Laporan dibuat',
          actor: draft.reportedBy,
          timestamp: DateTime.now(),
        ),
      ],
    );

    _items = [created, ..._items];
    _selectedItemId = created.id;
    _query = '';
    _statusFilter = null;
    notifyListeners();

    return created;
  }

  LostFoundItem? updateReport(String id, ReportDraft draft) {
    final item = itemById(id);
    if (item == null) {
      return null;
    }

    final updated = item.copyWith(
      title: draft.title,
      type: draft.type,
      category: draft.category,
      location: draft.location,
      description: draft.description,
      reportedBy: draft.reportedBy,
      contact: draft.contact,
      priority: draft.priority,
      activities: [
        ActivityLog(
          message: 'Laporan diperbarui',
          actor: draft.reportedBy.isNotEmpty ? draft.reportedBy : 'Staff Lost and Found',
          timestamp: DateTime.now(),
        ),
        ...item.activities,
      ],
    );

    _items = [
      for (final current in _items)
        if (current.id == item.id) updated else current,
    ];
    _selectedItemId = updated.id;
    _syncSelection();
    notifyListeners();

    return updated;
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

  int _resolveNextIdNumber(List<LostFoundItem> items) {
    final highest = items
        .map((item) => int.tryParse(item.id.replaceFirst('LF-', '')) ?? 0)
        .fold<int>(1000, (max, value) => value > max ? value : max);
    return highest + 1;
  }
}
