import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lost_and_found/core/utils/date_formatter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;
  String? _phoneNumber;
  bool _isLoadingPhone = true;

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
  }

  Future<void> _fetchPhoneNumber() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('phone')
            .select('phone_number')
            .eq('id', user.id)
            .maybeSingle();
        if (mounted) {
          setState(() {
            _phoneNumber = data?['phone_number'] as String?;
            _isLoadingPhone = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPhone = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda telah keluar dari akun.'),
            backgroundColor: Color(0xFF04756F),
          ),
        );
        // AuthWrapper will handle popping routes automatically via onAuthStateChange
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal keluar dari akun.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  Future<void> _showEditProfileDialog(String currentName, String? currentPhone) async {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone ?? '');
    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Edit Profil',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Baru',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final newName = nameController.text.trim();
                                  final newPhone = phoneController.text.trim();
                                  
                                  if ((newName.isEmpty || newName == currentName) && 
                                      (newPhone.isEmpty || newPhone == (currentPhone ?? ''))) {
                                    Navigator.of(context).pop();
                                    return;
                                  }
                                  
                                  setStateSheet(() => isLoading = true);
                                  try {
                                    if (newName.isNotEmpty && newName != currentName) {
                                      await Supabase.instance.client.auth.updateUser(
                                        UserAttributes(data: {'display_name': newName}),
                                      );
                                    }
                                    
                                    if (newPhone.isNotEmpty && newPhone != currentPhone) {
                                      final user = Supabase.instance.client.auth.currentUser;
                                      if (user != null) {
                                        // Insert or update phone
                                        await Supabase.instance.client.from('phone').upsert({
                                          'id': user.id,
                                          'phone_number': newPhone,
                                        });
                                      }
                                    }
                                    
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      _fetchPhoneNumber(); // Refresh phone data
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Profil berhasil diperbarui'),
                                          backgroundColor: Color(0xFF04756F),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setStateSheet(() => isLoading = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Gagal memperbarui profil'),
                                          backgroundColor: Colors.red.shade700,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Simpan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoggingOut = true);
    try {
      await Supabase.instance.client.rpc('delete_user');
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menghapus akun.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final email = user?.email ?? 'Tidak ada data';
    final displayName = user?.userMetadata?['display_name'] as String? ?? 'Pengguna';
    final rawDate = user?.createdAt != null ? DateTime.parse(user!.createdAt) : null;
    final joinedDate = rawDate != null ? formatDateTime(rawDate) : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x05000000),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile monogram avatar
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0x1A04756F),
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: const Color(0xFF04756F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _isLoadingPhone
                      ? const Center(child: SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)))
                      : Text(
                          _phoneNumber ?? 'Nomor telepon belum diisi',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Metadata list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bergabung Sejak',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        joinedDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tipe Akun',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Email & Password',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),
                  
                  // Edit Button
                  FilledButton(
                    onPressed: _isLoggingOut ? null : () => _showEditProfileDialog(displayName, _phoneNumber),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF04756F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Edit Profil',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Logout Button
                  FilledButton(
                    key: const ValueKey('logoutButton'),
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoggingOut
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Keluar Akun',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _isLoggingOut ? null : _handleDeleteAccount,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoggingOut
                        ? const SizedBox()
                        : const Text(
                            'Hapus Akun',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
