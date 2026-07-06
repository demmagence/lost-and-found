import '../models/lost_found_models.dart';

abstract interface class LostFoundRepository {
  Future<List<LostFoundItem>> loadItems();
  Future<LostFoundItem> addReport(ReportDraft draft);
  Future<LostFoundItem?> updateReport(String id, ReportDraft draft);
  Future<void> deleteReport(String id);
  Future<LostFoundItem?> changeStatus(String itemId, ItemStatus status);
}
