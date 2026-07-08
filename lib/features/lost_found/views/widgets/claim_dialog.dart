import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/lost_found_models.dart';

class ClaimDialog extends StatefulWidget {
  const ClaimDialog({super.key});

  @override
  State<ClaimDialog> createState() => _ClaimDialogState();
}

class _ClaimDialogState extends State<ClaimDialog> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  
  String _currentDisplayName = 'Pengguna Anonim';
  String _currentPhone = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final name = user.userMetadata?['display_name'] as String?;
      String? phone;
      try {
        final data = await Supabase.instance.client
            .from('phone')
            .select('phone_number')
            .eq('id', user.id)
            .maybeSingle();
        phone = data?['phone_number'] as String?;
      } catch (_) {}
      
      if (mounted) {
        setState(() {
          _currentDisplayName = name ?? user.email ?? 'Pengguna Anonim';
          _currentPhone = phone ?? user.phone ?? '';
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    final claim = ClaimRecord(
      claimantName: _currentDisplayName,
      contact: _currentPhone,
      note: _noteController.text.trim(),
      submittedAt: DateTime.now(),
      status: ClaimStatus.waiting,
    );
    
    Navigator.of(context).pop(claim);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajukan Klaim'),
      content: _isLoading 
        ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
        : Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Data kontak Anda akan otomatis dikirim ke pelapor agar bisa dihubungi.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Pesan / Bukti Kepemilikan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  hintText: 'Misal: "Casing hape warna merah ada stiker kucing"',
                ),
                maxLines: 3,
                validator: (value) => 
                  (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
            ],
          ),
        ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: const Text('Kirim Klaim'),
        ),
      ],
    );
  }
}
