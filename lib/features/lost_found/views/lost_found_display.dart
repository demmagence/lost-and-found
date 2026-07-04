import 'package:flutter/material.dart';

import '../models/lost_found_models.dart';

extension ItemTypeVisuals on ItemType {
  IconData get icon {
    return switch (this) {
      ItemType.found => Icons.inventory_2_outlined,
      ItemType.lost => Icons.search_outlined,
    };
  }
}

extension ItemStatusVisuals on ItemStatus {
  IconData get icon {
    return switch (this) {
      ItemStatus.open => Icons.radio_button_unchecked,
      ItemStatus.claimReview => Icons.rate_review_outlined,
      ItemStatus.matched => Icons.link_outlined,
      ItemStatus.returned => Icons.assignment_turned_in_outlined,
      ItemStatus.archived => Icons.archive_outlined,
    };
  }

  Color color(ColorScheme scheme) {
    return switch (this) {
      ItemStatus.open => const Color(0xFF3E6B7D),
      ItemStatus.claimReview => const Color(0xFF9A5A00),
      ItemStatus.matched => scheme.primary,
      ItemStatus.returned => const Color(0xFF2F7D32),
      ItemStatus.archived => const Color(0xFF6E6874),
    };
  }
}

extension ItemCategoryVisuals on ItemCategory {
  IconData get icon {
    return switch (this) {
      ItemCategory.electronics => Icons.devices_other_outlined,
      ItemCategory.documents => Icons.description_outlined,
      ItemCategory.bags => Icons.work_outline,
      ItemCategory.keys => Icons.key_outlined,
      ItemCategory.clothing => Icons.checkroom_outlined,
      ItemCategory.other => Icons.category_outlined,
    };
  }

  Color color(ColorScheme scheme) {
    return switch (this) {
      ItemCategory.electronics => scheme.primary,
      ItemCategory.documents => const Color(0xFF526D82),
      ItemCategory.bags => const Color(0xFF8A5A44),
      ItemCategory.keys => const Color(0xFF7B5EA7),
      ItemCategory.clothing => const Color(0xFFB35C7A),
      ItemCategory.other => const Color(0xFF5F6F52),
    };
  }
}

extension ItemPriorityVisuals on ItemPriority {
  IconData get icon {
    return switch (this) {
      ItemPriority.low => Icons.keyboard_arrow_down,
      ItemPriority.normal => Icons.drag_handle,
      ItemPriority.high => Icons.priority_high,
    };
  }
}
