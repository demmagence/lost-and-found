import 'package:flutter/material.dart';

import '../data/lost_found_repository.dart';
import '../models/lost_found_models.dart';
import '../viewmodels/lost_found_view_model.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/item_browser.dart';
import 'widgets/item_detail_panel.dart';
import 'widgets/report_dialog.dart';

class LostFoundHomePage extends StatefulWidget {
  const LostFoundHomePage({super.key, required this.repository});

  final LostFoundRepository repository;

  @override
  State<LostFoundHomePage> createState() => _LostFoundHomePageState();
}

class _LostFoundHomePageState extends State<LostFoundHomePage> {
  late final LostFoundViewModel _viewModel;
  late final TextEditingController _searchController;
  late final TextEditingController _appBarSearchController;
  int _currentTabIndex = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _viewModel = LostFoundViewModel(repository: widget.repository);
    _searchController = TextEditingController();
    _appBarSearchController = TextEditingController();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _searchController.dispose();
    _appBarSearchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    final newIndex = switch (_viewModel.typeFilter) {
      null => 0,
      ItemType.found => 1,
      ItemType.lost => 2,
    };
    if (_currentTabIndex != newIndex) {
      setState(() {
        _currentTabIndex = newIndex;
      });
    }
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _appBarSearchController.clear();
      _viewModel.setQuery('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final padding = isWide ? 24.0 : 16.0;

            // Show search in AppBar only on mobile non-Beranda tabs
            final showAppBarSearch = !isWide && _currentTabIndex != 0;

            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                bottom: _viewModel.isLoading
                    ? const PreferredSize(
                        preferredSize: Size.fromHeight(2),
                        child: LinearProgressIndicator(minHeight: 2),
                      )
                    : null,
                leading: (showAppBarSearch && _isSearching)
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _stopSearch,
                      )
                    : null,
                title: (showAppBarSearch && _isSearching)
                    ? TextField(
                        key: const ValueKey('appBarSearchField'),
                        controller: _appBarSearchController,
                        autofocus: true,
                        onChanged: _viewModel.setQuery,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: 'Cari barang...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      )
                    : DashboardHeader(
                        title: isWide
                            ? 'Lost and Found'
                            : switch (_currentTabIndex) {
                                0 => 'Beranda',
                                1 => 'Ditemukan',
                                2 => 'Hilang',
                                _ => 'Lost and Found',
                              },
                      ),
                titleSpacing: padding,
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 72,
                actions: [
                  if (showAppBarSearch && !_isSearching) ...[  
                    IconButton(
                      key: const ValueKey('appBarFilterButton'),
                      iconSize: 24.0,
                      icon: Badge(
                        isLabelVisible: _viewModel.statusFilter != null,
                        child: const Icon(Icons.tune),
                      ),
                      onPressed: () => _openFilterSheet(context),
                    ),
                    IconButton(
                      key: const ValueKey('appBarSearchButton'),
                      iconSize: 24.0,
                      icon: const Icon(Icons.search),
                      onPressed: _startSearch,
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.only(right: padding),
                    child: IconButton(
                      key: const ValueKey('appBarMonogram'),
                      iconSize: 32.0,
                      icon: const Icon(Icons.account_circle),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, bodyConstraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isWide) ...[
                            MetricsGrid(metrics: _viewModel.metrics),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: _contentHeight(bodyConstraints, isWide: true),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: 390,
                                    child: _buildBrowser(isWide: true),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ItemDetailPanel(
                                      item: _viewModel.selectedItem,
                                      onStatusChanged: (status) {
                                        final selected =
                                            _viewModel.selectedItem;
                                        if (selected != null) {
                                          _viewModel.changeStatus(
                                            selected.id,
                                            status,
                                          );
                                        }
                                      },
                                      onEdit: _openEditSheet,
                                      onDelete: (deletedItem) {
                                        _viewModel.deleteReport(deletedItem.id);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            if (_currentTabIndex == 0)
                              MetricsGrid(metrics: _viewModel.metrics)
                            else
                              SizedBox(
                                height: _contentHeight(bodyConstraints, isWide: false),
                                child: _buildBrowser(isWide: false),
                              ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ),
              floatingActionButton: (isWide || _currentTabIndex != 0)
                  ? FloatingActionButton(
                      key: const ValueKey('addReportButton'),
                      elevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      highlightElevation: 0,
                      onPressed: _openReportDialog,
                      child: const Icon(Icons.add),
                    )
                  : null,
              bottomNavigationBar: isWide
                  ? null
                  : NavigationBar(
                      selectedIndex: _currentTabIndex,
                      onDestinationSelected: (index) {
                        _stopSearch();
                        _viewModel.setTypeFilter(
                          switch (index) {
                            0 => null,
                            1 => ItemType.found,
                            2 => ItemType.lost,
                            _ => null,
                          },
                        );
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Beranda',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.inventory_2_outlined),
                          selectedIcon: Icon(Icons.inventory_2),
                          label: 'Ditemukan',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.search_outlined),
                          selectedIcon: Icon(Icons.search),
                          label: 'Hilang',
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildBrowser({required bool isWide}) {
    return ItemBrowser(
      showTypeFilters: isWide,
      showSearchBar: isWide,
      showStatusFilter: isWide,
      showOuterBorder: isWide,
      items: _viewModel.filteredItems,
      selectedItem: _viewModel.selectedItem,
      searchController: _searchController,
      query: _viewModel.query,
      typeFilter: _viewModel.typeFilter,
      statusFilter: _viewModel.statusFilter,
      onQueryChanged: _viewModel.setQuery,
      onTypeChanged: _viewModel.setTypeFilter,
      onStatusChanged: _viewModel.setStatusFilter,
      onClearFilters: () {
        _viewModel.clearFilters();
        _searchController.clear();
        _appBarSearchController.clear();
      },
      onSelectItem: (item) => _selectItem(item, isWide),
    );
  }

  void _openFilterSheet(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Filter Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _viewModel.setStatusFilter(null);
                          setSheetState(() {});
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Semua'),
                            selected: _viewModel.statusFilter == null,
                            side: BorderSide.none,
                            onSelected: (_) {
                              _viewModel.setStatusFilter(null);
                              setSheetState(() {});
                            },
                          ),
                          for (final status in ItemStatus.values)
                            ChoiceChip(
                              key: ValueKey('sheetFilter-${status.name}'),
                              label: Text(status.label),
                              selected: _viewModel.statusFilter == status,
                              side: BorderSide.none,
                              onSelected: (_) {
                                _viewModel.setStatusFilter(status);
                                setSheetState(() {});
                              },
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }


  double _contentHeight(BoxConstraints constraints, {required bool isWide}) {
    // Reserve space for the gaps (16 + 16) + metrics row (~220) + bottom padding (~16).
    // The appBar height (~72) is already reserved at Scaffold level.
    final hasMetrics = isWide || _currentTabIndex == 0;
    final metricsHeight = hasMetrics ? 220 : 0;
    final reserved = 16 + metricsHeight + 16 + 16;
    final available = constraints.maxHeight - reserved;
    if (isWide) {
      return available > 560 ? available : 560;
    }
    return available > 360 ? available : 360;
  }
  void _selectItem(LostFoundItem item, bool isWide) {
    _viewModel.selectItem(item);

    if (!isWide) {
      _showItemSheet(item);
    }
  }

  void _showItemSheet(LostFoundItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final sheetItem = _viewModel.itemById(item.id) ?? item;

            return FractionallySizedBox(
              heightFactor: 0.92,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: ItemDetailPanel(
                   item: sheetItem,
                   compact: true,
                   onStatusChanged: (status) {
                     _viewModel.changeStatus(sheetItem.id, status);
                   },
                   onEdit: (editedItem) {
                     Navigator.of(context).pop();
                     _openEditSheet(editedItem);
                   },
                   onDelete: (deletedItem) {
                     Navigator.of(context).pop();
                     _viewModel.deleteReport(deletedItem.id);
                   },
                 ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openReportDialog() async {
    final initialType = switch (_currentTabIndex) {
      1 => ItemType.found,
      2 => ItemType.lost,
      _ => null,
    };

    final draft = await showModalBottomSheet<ReportDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDialog(fixedType: initialType),
    );

    if (draft == null) {
      return;
    }

    _viewModel.addReport(draft);
    _searchController.clear();
  }

  Future<void> _openEditSheet(LostFoundItem item) async {
    final draft = await showModalBottomSheet<ReportDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDialog(initialItem: item),
    );

    if (draft == null) {
      return;
    }

    _viewModel.updateReport(item.id, draft);
  }
}

