import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/lost_found_app.dart';
import '../../lost_found/data/lost_found_repository.dart';
import '../../lost_found/views/lost_found_home_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({
    super.key,
    required this.repository,
    this.bypassAuth = false,
  });

  final LostFoundRepository repository;
  final bool bypassAuth;

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isAuthenticated = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();
    
    // Listen to Auth State Changes reactively
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final newAuth = session != null;
      if (newAuth != _isAuthenticated) {
        setState(() {
          _isAuthenticated = newAuth;
          _loading = false;
        });
        
        // If user logs out, pop all pushed screens to return clean to the LoginPage root
        if (!newAuth && !widget.bypassAuth) {
          MainApp.navigatorKey.currentState?.popUntil((route) => route.isFirst);
        }
      } else {
        if (_loading) {
          setState(() {
            _loading = false;
          });
        }
      }
    });
  }

  void _checkInitialAuth() {
    if (widget.bypassAuth) {
      _isAuthenticated = true;
      _loading = false;
      return;
    }
    final session = Supabase.instance.client.auth.currentSession;
    _isAuthenticated = session != null;
    _loading = false;
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF04756F),
          ),
        ),
      );
    }

    if (_isAuthenticated || widget.bypassAuth) {
      return LostFoundHomePage(
        repository: widget.repository,
        bypassAuth: widget.bypassAuth,
      );
    } else {
      return const LoginPage();
    }
  }
}
