import 'package:flutter/material.dart';

import '../../models/lost_found_models.dart';
import '../lost_found_display.dart';
import 'shared_widgets.dart';

class ItemBrowser extends StatelessWidget {
  const ItemBrowser({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.searchController,
    required this.query,
    required this.typeFilter,
    required this.statusFilter,
    required this.onQueryChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.onSelectItem,
    this.showTypeFilters = true,
    this.showSearchBar = true,
    this.showStatusFilter = true,
    this.showOuterBorder = true,
  });

  final bool showTypeFilters;
  final bool showSearchBar;
  final bool showStatusFilter;
  final bool showOuterBorder;

  final List<LostFoundItem> items;
  final LostFoundItem? selectedItem;
  final TextEditingController searchController;
  final String query;
  final ItemType? typeFilter;
  final ItemStatus? statusFilter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ItemType?> onTypeChanged;
  final ValueChanged<ItemStatus?> onStatusChanged;
  final VoidCallback onClearFilters;
  final ValueChanged<LostFoundItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAnyFilter = showSearchBar || showTypeFilters || showStatusFilter;

    return Container(
      decoration: showOuterBorder
          ? BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.outlineVariant),
            )
          : null,
      child: Column(
        children: [
          if (hasAnyFilter)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showSearchBar)
                    TextField(
                      key: const ValueKey('itemSearchField'),
                      controller: searchController,
                      onChanged: onQueryChanged,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Cari barang, lokasi, atau pelapor',
                      ),
                    ),
                  if (showTypeFilters) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          key: const ValueKey('filterAllTypes'),
                          label: const Text('Semua'),
                          selected: typeFilter == null,
                          onSelected: (_) => onTypeChanged(null),
                        ),
                        ChoiceChip(
                          key: const ValueKey('filterFound'),
                          avatar: const Icon(Icons.inventory_2_outlined, size: 18),
                          label: const Text('Ditemukan'),
                          selected: typeFilter == ItemType.found,
                          onSelected: (_) => onTypeChanged(ItemType.found),
                        ),
                        ChoiceChip(
                          key: const ValueKey('filterLost'),
                          avatar: const Icon(Icons.search_outlined, size: 18),
                          label: const Text('Hilang'),
                          selected: typeFilter == ItemType.lost,
                          onSelected: (_) => onTypeChanged(ItemType.lost),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (showStatusFilter)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            key: const ValueKey('filterStatusAll'),
                            label: const Text('Semua status'),
                            selected: statusFilter == null,
                            side: BorderSide.none,
                            onSelected: (_) => onStatusChanged(null),
                          ),
                          const SizedBox(width: 8),
                          for (final status in ItemStatus.values) ...[
                            ChoiceChip(
                              key: ValueKey('filterStatus-${status.name}'),
                              label: Text(status.label),
                              selected: statusFilter == status,
                              side: BorderSide.none,
                              onSelected: (_) => onStatusChanged(status),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (showOuterBorder) Divider(height: 1, color: scheme.outlineVariant),
          Expanded(
            child: items.isEmpty
                ? const _EmptyList()
                : ListView.separated(
                    padding: showOuterBorder
                        ? const EdgeInsets.fromLTRB(12, 12, 12, 12)
                        : const EdgeInsets.fromLTRB(0, 8, 0, 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ItemListTile(
                        item: item,
                        selected: showOuterBorder && item.id == selectedItem?.id,
                        onTap: () => onSelectItem(item),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemCount: items.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ItemListTile extends StatelessWidget {
  const _ItemListTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final LostFoundItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = item.category.color(scheme);

    final tileColor = selected
        ? scheme.primaryContainer.withValues(alpha: 0.38)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return Material(
      key: ValueKey('item-card-${item.id}'),
      color: tileColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(minHeight: 72),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ItemPhotoPlaceholder(item: item, size: 44, iconSize: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.type.label} | ${item.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        MiniPill(
                          label: item.status.label,
                          color: item.status.color(scheme),
                        ),
                        MiniPill(label: item.category.label, color: accent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.maxHeight > 48
            ? constraints.maxHeight - 48
            : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_outlined,
                    size: 44,
                    color: scheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada hasil',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coba kata kunci atau status lain.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
