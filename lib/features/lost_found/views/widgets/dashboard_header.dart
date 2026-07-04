import 'package:flutter/material.dart';

import '../../models/lost_found_models.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      title,
      style: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({super.key, required this.metrics});

  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 2;
        const gap = 12.0;
        final tileWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        final tiles = [
          _MetricTile(
            label: 'Ditemukan',
            value: metrics.found,
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF04756F),
          ),
          _MetricTile(
            label: 'Hilang',
            value: metrics.lost,
            icon: Icons.search_outlined,
            color: const Color(0xFF526D82),
          ),
          _MetricTile(
            label: 'Menunggu',
            value: metrics.pendingClaims,
            icon: Icons.rate_review_outlined,
            color: const Color(0xFF9A5A00),
          ),
          _MetricTile(
            label: 'Terselesaikan',
            value: metrics.resolved,
            icon: Icons.assignment_turned_in_outlined,
            color: const Color(0xFF2F7D32),
          ),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles)
              SizedBox(width: tileWidth, height: 104, child: tile),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
