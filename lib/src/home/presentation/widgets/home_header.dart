import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/auth/presentation/providers/auth_provider.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    // Après 2 secondes, le header disparaît (réduit à 0)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final firstName = user?.firstName ?? user?.fullName ?? '...';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          height: _isVisible ? 100 : 0,
          color: Colors.white,
          child: _isVisible
              ? Center(
                  child: Text(
                    firstName,
                    key: ValueKey(firstName),
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}