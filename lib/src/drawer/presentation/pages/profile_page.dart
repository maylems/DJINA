import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:djina_debug/src/auth/presentation/providers/auth_provider.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/drawer_header.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/custom_text_field.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/custom_button.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/gender_button.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/phone_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _surnomController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isMrSelected = true;

  @override
  void initState() {
    super.initState();
    // Pré-remplir après le premier frame (AuthProvider déjà chargé)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fillFromUser();
    });
  }

  void _fillFromUser() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    _nomController.text = user.firstName ?? '';
    _surnomController.text = user.lastName ?? '';
    _emailController.text = user.email;

    // Retire le +221 pour l'affichage dans PhoneField
    final rawPhone = user.phone.replaceFirst('+221', '').trim();
    _phoneController.text = rawPhone;

    // La date n'est pas dans UserModel → on garde le placeholder
    if (_dateController.text.isEmpty) {
      _dateController.text = '18 Juillet 1995';
    }

    setState(() {}); // rafraîchit les champs
  }

  @override
  void dispose() {
    _nomController.dispose();
    _surnomController.dispose();
    _dateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomDrawerHeader(),

            Expanded(
              child: SingleChildScrollView(
                // ← scroll pour éviter overflow sur petits écrans
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar + nom en haut ───────────────────────────
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final user = authProvider.currentUser;
                        final displayName = user?.fullName ?? '';
                        final profileImage = user?.profileImage;

                        return Column(
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.circle,
                                      image: profileImage != null
                                          ? DecorationImage(
                                              image:
                                                  NetworkImage(profileImage),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: profileImage == null
                                        ? Center(
                                            child: Text(
                                              _initials(displayName),
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  // Bouton caméra
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.camera_alt,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (displayName.isNotEmpty)
                              Center(
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              ),
                            if (user?.email != null)
                              Center(
                                child: Text(
                                  user!.email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // Titre PROFILE
                    const Text(
                      'PROFILE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _nomController,
                      placeholder: 'Prénom',
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _surnomController,
                      placeholder: 'Nom de famille',
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: GenderButton(
                            text: 'Mr',
                            isSelected: _isMrSelected,
                            onTap: () => setState(() => _isMrSelected = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GenderButton(
                            text: 'Mm',
                            isSelected: !_isMrSelected,
                            onTap: () => setState(() => _isMrSelected = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _dateController,
                      placeholder: '18 Juillet 1995',
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _emailController,
                      placeholder: 'Email',
                    ),
                    const SizedBox(height: 16),

                    PhoneField(controller: _phoneController),

                    const SizedBox(height: 40),

                    // ── Supprimer son compte ───────────────────────────
                    const Text(
                      'SUPPRIMER SON COMPTE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomButton(
                      text: 'Désactiver mon compte',
                      backgroundColor: AppTheme.cardColor,
                      onPressed: () {
                        // TODO: désactivation
                      },
                    ),
                    const SizedBox(height: 12),

                    CustomButton(
                      text: 'Supprimer mon compte',
                      backgroundColor: Colors.red,
                      onPressed: () {
                        // TODO: suppression
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}