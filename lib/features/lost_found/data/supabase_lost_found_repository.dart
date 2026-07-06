import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lost_found_models.dart';
import 'lost_found_repository.dart';

class SupabaseLostFoundRepository implements LostFoundRepository {
  SupabaseLostFoundRepository();

  final _client = Supabase.instance.client;

  @override
  Future<List<LostFoundItem>> loadItems() async {
    final response = await _client
        .from('items')
        .select()
        .order('reported_at', ascending: false);
    
    return (response as List<dynamic>)
        .map((json) => LostFoundItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LostFoundItem> addReport(ReportDraft draft) async {
    // Generate sequential ID based on the highest existing ID number
    final response = await _client.from('items').select('id');
    final ids = (response as List<dynamic>).map((e) => e['id'] as String).toList();
    final highestNumber = ids
        .map((id) => int.tryParse(id.replaceFirst('LF-', '')) ?? 0)
        .fold<int>(1000, (max, val) => val > max ? val : max);
    final nextId = 'LF-${highestNumber + 1}';

    final newItem = LostFoundItem(
      id: nextId,
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

    await _client.from('items').insert(newItem.toJson());
    return newItem;
  }

  @override
  Future<LostFoundItem?> updateReport(String id, ReportDraft draft) async {
    final response = await _client.from('items').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    final item = LostFoundItem.fromJson(response);

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

    await _client.from('items').update(updated.toJson()).eq('id', id);
    return updated;
  }

  @override
  Future<void> deleteReport(String id) async {
    await _client.from('items').delete().eq('id', id);
  }

  @override
  Future<LostFoundItem?> changeStatus(String itemId, ItemStatus status) async {
    final response = await _client.from('items').select().eq('id', itemId).maybeSingle();
    if (response == null) return null;
    final item = LostFoundItem.fromJson(response);

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

    await _client.from('items').update(updated.toJson()).eq('id', itemId);
    return updated;
  }
}
