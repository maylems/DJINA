import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/auth/presentation/controllers/auth_controller.dart';
import 'package:djina_debug/src/auth/presentation/pages/signup_page.dart';
import 'package:djina_debug/src/auth/presentation/providers/auth_provider.dart';
import 'package:djina_debug/src/auth/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  /// Email pré-rempli après vérification OTP (flux inscription → login)
  final String? prefillEmail;

  const LoginPage({super.key, this.prefillEmail});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      authProvider.resetLoginForm();

      if (widget.prefillEmail != null) {
        authProvider.emailLoginController.text = widget.prefillEmail!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.primaryColor,
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
                          'SE CONNECTER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Bandeau vert après vérification OTP
                        if (widget.prefillEmail != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green.shade600, size: 18),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Compte vérifié ! Connectez-vous.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ErrorMessage(
                          message: authProvider.errorMessage,
                          onDismiss: () => AuthController.clearError(context),
                        ),

                        // Email uniquement
                        CustomTextField(
                          controller: authProvider.emailLoginController,
                          label: 'Email',
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
                        const SizedBox(height: 22),

                        AuthButton(
                          text: 'Connecter',
                          isLoading: authProvider.isLoginLoading,
                          onPressed: authProvider.isLoginFormValid
                              ? () => AuthController.login(context)
                              : null,
                        ),
                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupPage()),
                          ),
                          child: const Text(
                            'Créer un compte',
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