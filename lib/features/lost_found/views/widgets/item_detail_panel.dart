import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/utils/date_formatter.dart';
import '../../models/lost_found_models.dart';
import '../lost_found_display.dart';
import 'shared_widgets.dart';

class ItemDetailPanel extends StatelessWidget {
  const ItemDetailPanel({
    super.key,
    required this.item,
    required this.onStatusChanged,
    required this.onSubmitClaim,
    required this.onResolveClaim,
    required this.onEdit,
    required this.onDelete,
    this.compact = false,
  });

  final LostFoundItem? item;
  final ValueChanged<ItemStatus> onStatusChanged;
  final ValueChanged<ClaimRecord> onSubmitClaim;
  final void Function(ClaimStatus claimStatus, ItemStatus itemStatus) onResolveClaim;
  final ValueChanged<LostFoundItem> onEdit;
  final ValueChanged<LostFoundItem> onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    final scheme = Theme.of(context).colorScheme;

    if (item == null) {
      return Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: compact ? null : Border.all(color: scheme.outlineVariant),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.manage_search_outlined,
                size: 52,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada barang yang cocok',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Ubah kata kunci atau filter untuk melihat data lain.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      key: const ValueKey('detailPanel'),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: compact ? null : Border.all(color: scheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact)
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DetailHeader(item: item, compact: compact),
                ),
                if (sb.Supabase.instance.client.auth.currentUser?.id == item.userId) ...[
                  IconButton(
                    key: const ValueKey('editReportButton'),
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => onEdit(item),
                    tooltip: 'Edit Laporan',
                  ),
                  IconButton(
                    key: const ValueKey('deleteReportButton'),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _confirmDelete(context, item),
                    tooltip: 'Hapus Laporan',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            SectionTitle(
              icon: Icons.tune_outlined,
              label: 'Aksi status',
              trailing: _StatusPill(item: item),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.status == ItemStatus.open)
                  FilledButton.tonalIcon(
                    key: const ValueKey('action-submit-claim'),
                    onPressed: () => onStatusChanged(ItemStatus.claimReview), // Will be intercepted in parent
                    icon: const Icon(Icons.handshake_outlined, size: 18),
                    label: const Text('Ajukan Klaim'),
                  ),
                if (item.status == ItemStatus.claimReview) ...[
                  FilledButton.tonalIcon(
                    key: const ValueKey('action-accept-claim'),
                    onPressed: () => onResolveClaim(ClaimStatus.approved, ItemStatus.matched),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Terima Klaim'),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    key: const ValueKey('action-reject-claim'),
                    onPressed: () => onResolveClaim(ClaimStatus.rejected, ItemStatus.open),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Tolak Klaim'),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.errorContainer,
                      foregroundColor: scheme.onErrorContainer,
                    ),
                  ),
                ],
                if (item.status == ItemStatus.matched)
                  FilledButton.tonalIcon(
                    key: const ValueKey('action-mark-returned'),
                    onPressed: () => onStatusChanged(ItemStatus.returned),
                    icon: const Icon(Icons.assignment_returned_outlined, size: 18),
                    label: const Text('Selesaikan & Kembalikan'),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.tertiaryContainer,
                      foregroundColor: scheme.onTertiaryContainer,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            const SectionTitle(
              icon: Icons.notes_outlined,
              label: 'Detail laporan',
            ),
            const SizedBox(height: 10),
            _InfoGrid(item: item),
            const SizedBox(height: 18),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle(
              icon: Icons.verified_user_outlined,
              label: 'Klaim',
            ),
            const SizedBox(height: 10),
            _ClaimPanel(item: item),
            const SizedBox(height: 22),
            const SectionTitle(icon: Icons.history_outlined, label: 'Riwayat'),
            const SizedBox(height: 10),
            _ActivityTimeline(activities: item.activities),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, LostFoundItem item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(ctx).colorScheme.error,
        ),
        title: const Text('Hapus Laporan?'),
        content: Text(
          'Laporan "${item.title}" akan dihapus secara permanen dan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const ValueKey('confirmDeleteButton'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete(item);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.item, required this.compact});

  final LostFoundItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = Text(
      item.title,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
    );
    final metadata = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MiniPill(
              label: item.type.reportLabel,
              color: item.type == ItemType.found
                  ? scheme.primary
                  : const Color(0xFF526D82),
            ),
            MiniPill(
              label: item.priority.label,
              color: item.priority == ItemPriority.high
                  ? const Color(0xFFB3261E)
                  : scheme.secondary,
              icon: item.priority.icon,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${item.id} | ${formatDateTime(item.reportedAt)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemPhotoPlaceholder(item: item, size: 148, iconSize: 58),
          const SizedBox(height: 14),
          metadata,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ItemPhotoPlaceholder(item: item, size: 148, iconSize: 58),
        const SizedBox(width: 18),
        Expanded(child: metadata),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.item});

  final LostFoundItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 2 : 1;
        const gap = 10.0;
        final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;
        final blocks = [
          _InfoBlock(
            label: 'Kategori',
            value: item.category.label,
            icon: item.category.icon,
          ),
          _InfoBlock(
            label: 'Lokasi',
            value: item.location,
            icon: Icons.place_outlined,
          ),
          _InfoBlock(
            label: 'Pelapor',
            value: item.reportedBy,
            icon: Icons.person_outline,
          ),
          _InfoBlock(
            label: 'Kontak',
            value: item.contact.isEmpty ? 'Belum dicatat' : item.contact,
            icon: Icons.phone_outlined,
          ),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final block in blocks) SizedBox(width: width, child: block),
          ],
        );
      },
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimPanel extends StatelessWidget {
  const _ClaimPanel({required this.item});

  final LostFoundItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final claim = item.claim;

    if (claim == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Belum ada klaim aktif untuk barang ini.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.badge_outlined, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.claimantName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${claim.status.label} | ${formatDateTime(claim.submittedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            claim.note,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            claim.contact,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline({required this.activities});

  final List<ActivityLog> activities;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final (index, activity) in activities.indexed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: index == 0 ? scheme.primary : scheme.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index != activities.length - 1)
                    Container(
                      width: 1,
                      height: 46,
                      color: scheme.outlineVariant,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${activity.actor} | ${formatDateTime(activity.timestamp)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.item});

  final LostFoundItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = item.status.color(scheme);

    return Container(
      key: const ValueKey('detailStatusLabel'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.status.icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            item.status.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
