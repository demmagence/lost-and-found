enum ItemType { found, lost }

extension ItemTypeLabels on ItemType {
  String get label {
    return switch (this) {
      ItemType.found => 'Ditemukan',
      ItemType.lost => 'Hilang',
    };
  }

  String get reportLabel {
    return switch (this) {
      ItemType.found => 'Barang ditemukan',
      ItemType.lost => 'Barang hilang',
    };
  }
}

enum ItemStatus { open, claimReview, matched, returned, archived }

extension ItemStatusLabels on ItemStatus {
  String get label {
    return switch (this) {
      ItemStatus.open => 'Terbuka',
      ItemStatus.claimReview => 'Klaim Ditinjau',
      ItemStatus.matched => 'Cocok',
      ItemStatus.returned => 'Dikembalikan',
      ItemStatus.archived => 'Diarsipkan',
    };
  }

  String get actionLabel {
    return switch (this) {
      ItemStatus.open => 'Buka Ulang',
      ItemStatus.claimReview => 'Tinjau Klaim',
      ItemStatus.matched => 'Tandai Cocok',
      ItemStatus.returned => 'Tandai Kembali',
      ItemStatus.archived => 'Arsipkan',
    };
  }
}

enum ItemCategory { electronics, documents, bags, keys, clothing, other }

extension ItemCategoryLabels on ItemCategory {
  String get label {
    return switch (this) {
      ItemCategory.electronics => 'Elektronik',
      ItemCategory.documents => 'Dokumen',
      ItemCategory.bags => 'Tas & Dompet',
      ItemCategory.keys => 'Kunci',
      ItemCategory.clothing => 'Pakaian',
      ItemCategory.other => 'Lainnya',
    };
  }
}

enum ItemPriority { low, normal, high }

extension ItemPriorityLabels on ItemPriority {
  String get label {
    return switch (this) {
      ItemPriority.low => 'Rendah',
      ItemPriority.normal => 'Normal',
      ItemPriority.high => 'Tinggi',
    };
  }
}

enum ClaimStatus { waiting, approved, rejected }

extension ClaimStatusLabels on ClaimStatus {
  String get label {
    return switch (this) {
      ClaimStatus.waiting => 'Menunggu verifikasi',
      ClaimStatus.approved => 'Disetujui',
      ClaimStatus.rejected => 'Ditolak',
    };
  }
}

class ActivityLog {
  const ActivityLog({
    required this.message,
    required this.actor,
    required this.timestamp,
  });

  final String message;
  final String actor;
  final DateTime timestamp;

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      message: json['message'] as String,
      actor: json['actor'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'actor': actor,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ClaimRecord {
  const ClaimRecord({
    required this.claimantName,
    required this.contact,
    required this.note,
    required this.submittedAt,
    required this.status,
  });

  final String claimantName;
  final String contact;
  final String note;
  final DateTime submittedAt;
  final ClaimStatus status;

  factory ClaimRecord.fromJson(Map<String, dynamic> json) {
    return ClaimRecord(
      claimantName: json['claimantName'] as String,
      contact: json['contact'] as String,
      note: json['note'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      status: ClaimStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'claimantName': claimantName,
      'contact': contact,
      'note': note,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status.name,
    };
  }
}

class LostFoundItem {
  const LostFoundItem({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.location,
    required this.description,
    required this.reportedBy,
    required this.contact,
    required this.reportedAt,
    required this.status,
    required this.priority,
    required this.activities,
    this.claim,
  });

  final String id;
  final String title;
  final ItemType type;
  final ItemCategory category;
  final String location;
  final String description;
  final String reportedBy;
  final String contact;
  final DateTime reportedAt;
  final ItemStatus status;
  final ItemPriority priority;
  final ClaimRecord? claim;
  final List<ActivityLog> activities;

  factory LostFoundItem.fromJson(Map<String, dynamic> json) {
    final claimJson = json['claim'];
    return LostFoundItem(
      id: json['id'] as String,
      title: json['title'] as String,
      type: ItemType.values.firstWhere((e) => e.name == json['type']),
      category: ItemCategory.values.firstWhere((e) => e.name == json['category']),
      location: json['location'] as String,
      description: json['description'] as String,
      reportedBy: json['reported_by'] as String,
      contact: json['contact'] as String,
      reportedAt: DateTime.parse(json['reported_at'] as String),
      status: ItemStatus.values.firstWhere((e) => e.name == json['status']),
      priority: ItemPriority.values.firstWhere((e) => e.name == json['priority']),
      claim: claimJson != null ? ClaimRecord.fromJson(claimJson as Map<String, dynamic>) : null,
      activities: (json['activities'] as List<dynamic>)
          .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'category': category.name,
      'location': location,
      'description': description,
      'reported_by': reportedBy,
      'contact': contact,
      'reported_at': reportedAt.toIso8601String(),
      'status': status.name,
      'priority': priority.name,
      'claim': claim?.toJson(),
      'activities': activities.map((e) => e.toJson()).toList(),
    };
  }

  LostFoundItem copyWith({
    String? id,
    String? title,
    ItemType? type,
    ItemCategory? category,
    String? location,
    String? description,
    String? reportedBy,
    String? contact,
    DateTime? reportedAt,
    ItemStatus? status,
    ItemPriority? priority,
    ClaimRecord? claim,
    List<ActivityLog>? activities,
  }) {
    return LostFoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      category: category ?? this.category,
      location: location ?? this.location,
      description: description ?? this.description,
      reportedBy: reportedBy ?? this.reportedBy,
      contact: contact ?? this.contact,
      reportedAt: reportedAt ?? this.reportedAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      claim: claim ?? this.claim,
      activities: activities ?? this.activities,
    );
  }
}

class ReportDraft {
  const ReportDraft({
    required this.title,
    required this.type,
    required this.category,
    required this.location,
    required this.description,
    required this.reportedBy,
    required this.contact,
    required this.priority,
  });

  final String title;
  final ItemType type;
  final ItemCategory category;
  final String location;
  final String description;
  final String reportedBy;
  final String contact;
  final ItemPriority priority;
}

class DashboardMetrics {
  const DashboardMetrics({
    required this.found,
    required this.lost,
    required this.pendingClaims,
    required this.resolved,
  });

  final int found;
  final int lost;
  final int pendingClaims;
  final int resolved;
}
