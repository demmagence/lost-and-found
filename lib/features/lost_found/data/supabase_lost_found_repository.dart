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
      userId: _client.auth.currentUser?.id,
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
  @override
  Future<LostFoundItem?> submitClaim(String itemId, ClaimRecord claim) async {
    final response = await _client.from('items').select().eq('id', itemId).maybeSingle();
    if (response == null) return null;
    final item = LostFoundItem.fromJson(response);

    final updated = item.copyWith(
      status: ItemStatus.claimReview,
      claim: claim,
      activities: [
        ActivityLog(
          message: 'Klaim diajukan oleh ${claim.claimantName}',
          actor: claim.claimantName,
          timestamp: DateTime.now(),
        ),
        ...item.activities,
      ],
    );

    await _client.from('items').update({
      'status': updated.status.name,
      'claim': updated.claim?.toJson(),
      'activities': updated.activities.map((a) => a.toJson()).toList(),
    }).eq('id', itemId);
    return updated;
  }

  @override
  Future<LostFoundItem?> resolveClaim(String itemId, ClaimStatus claimStatus, ItemStatus itemStatus) async {
    final response = await _client.from('items').select().eq('id', itemId).maybeSingle();
    if (response == null) return null;
    final item = LostFoundItem.fromJson(response);

    final updatedClaim = item.claim != null
        ? ClaimRecord(
            claimantName: item.claim!.claimantName,
            contact: item.claim!.contact,
            note: item.claim!.note,
            submittedAt: item.claim!.submittedAt,
            status: claimStatus,
          )
        : null;

    final updated = item.copyWith(
      status: itemStatus,
      claim: claimStatus == ClaimStatus.rejected ? null : updatedClaim,
      activities: [
        ActivityLog(
          message: 'Klaim ditinjau dan ${claimStatus.label}. Status barang menjadi ${itemStatus.label}',
          actor: 'Sistem',
          timestamp: DateTime.now(),
        ),
        ...item.activities,
      ],
    );

    await _client.from('items').update({
      'status': updated.status.name,
      'claim': updated.claim?.toJson(),
      'activities': updated.activities.map((a) => a.toJson()).toList(),
    }).eq('id', itemId);
    return updated;
  }
}
