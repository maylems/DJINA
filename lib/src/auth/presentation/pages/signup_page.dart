import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/auth/presentation/controllers/auth_controller.dart';
import 'package:djina_debug/src/auth/presentation/providers/auth_provider.dart';
import 'package:djina_debug/src/auth/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Plus de ChangeNotifierProvider local : utilise le provider global
    return const _SignupPageContent();
  }
}

class _SignupPageContent extends StatelessWidget {
  const _SignupPageContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const AuthHeader(),
                SafeArea(
                  top: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: const BorderRadius.only(),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryColor,
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),

                        const Text(
                          'S\'INSCRIRE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 22),

                        ErrorMessage(
                          message: authProvider.errorMessage,
                          onDismiss: authProvider.clearError,
                        ),

                        CustomTextField(
                          controller: authProvider.phoneController,
                          label: 'Numéro de téléphone',
                          hintText: '00 000 00 00',
                          keyboardType: TextInputType.phone,
                          prefixText: '+221  |',
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          controller: authProvider.firstNameController,
                          label: 'Prénom',
                          hintText: 'Votre prénom',
                          keyboardType: TextInputType.name,
                          // textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          controller: authProvider.lastNameController,
                          label: 'Nom de famille',
                          hintText: 'Votre nom',
                          keyboardType: TextInputType.name,
                          // textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          controller: authProvider.emailController,
                          label: 'Email (optionnel)',
                          hintText: 'exemple@email.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        CustomTextField(
                          controller: authProvider.passwordController,
                          label: 'Mot de passe',
                          hintText: '********',
                          obscureText: authProvider.obscurePassword,
                          suffixIcon: Icon(
                            authProvider.obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onSuffixIconPressed: () =>
                              AuthController.togglePasswordVisibility(context),
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          controller: authProvider.referralCodeController,
                          label: 'Code de parrainage (optionnel)',
                          hintText: 'Ex: ABC123',
                          keyboardType: TextInputType.text,
                          // textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 12),

                        TermsCheckbox(
                          value: authProvider.acceptTerms,
                          onChanged: (_) =>
                              AuthController.toggleTermsAcceptance(context),
                        ),
                        const SizedBox(height: 22),

                        AuthButton(
                          text: 'Enregistrer',
                          isLoading: authProvider.isSignupLoading,
                          onPressed: authProvider.isSignupFormValid
                              ? () => AuthController.signup(context)
                              : null,
                        ),
                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}