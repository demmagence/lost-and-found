import 'package:flutter/material.dart';

import '../../models/lost_found_models.dart';
import '../lost_found_display.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({super.key, this.fixedType});

  final ItemType? fixedType;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reporterController = TextEditingController();
  final _contactController = TextEditingController();
  late ItemType _type;
  ItemCategory _category = ItemCategory.other;
  ItemPriority _priority = ItemPriority.normal;

  @override
  void initState() {
    super.initState();
    _type = widget.fixedType ?? ItemType.found;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _reporterController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Tambah laporan baru',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.fixedType == null) ...[
                          SegmentedButton<ItemType>(
                            key: const ValueKey('reportTypeSegment'),
                            showSelectedIcon: false,
                            segments: [
                              for (final type in ItemType.values)
                                ButtonSegment<ItemType>(
                                  value: type,
                                  icon: Icon(type.icon),
                                  label: Text(type.label),
                                ),
                            ],
                            selected: {_type},
                            onSelectionChanged: (selection) {
                              setState(() {
                                _type = selection.first;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          key: const ValueKey('reportTitleField'),
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Nama barang',
                            prefixIcon: Icon(Icons.label_outline),
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<ItemCategory>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: [
                            for (final category in ItemCategory.values)
                              DropdownMenuItem(
                                value: category,
                                child: Text(category.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _category = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<ItemPriority>(
                          initialValue: _priority,
                          decoration: const InputDecoration(
                            labelText: 'Prioritas',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          items: [
                            for (final priority in ItemPriority.values)
                              DropdownMenuItem(
                                value: priority,
                                child: Text(priority.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _priority = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('reportLocationField'),
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Lokasi terakhir',
                            prefixIcon: Icon(Icons.place_outlined),
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('reportReporterField'),
                          controller: _reporterController,
                          decoration: const InputDecoration(
                            labelText: 'Nama pelapor',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('reportContactField'),
                          controller: _contactController,
                          decoration: const InputDecoration(
                            labelText: 'Kontak',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('reportDescriptionField'),
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Catatan',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.notes_outlined),
                          ),
                          minLines: 3,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: const ValueKey('submitReportButton'),
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan laporan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      ReportDraft(
        title: _titleController.text.trim(),
        type: _type,
        category: _category,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? 'Belum ada catatan tambahan.'
            : _descriptionController.text.trim(),
        reportedBy: _reporterController.text.trim(),
        contact: _contactController.text.trim(),
        priority: _priority,
      ),
    );
  }
}
