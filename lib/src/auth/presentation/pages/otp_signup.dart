import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class OtpSignupPage extends StatelessWidget {
  const OtpSignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupérer le provider existant au lieu d'en créer un nouveau
    return const _OtpSignupPageContent();
  }
}

class _OtpSignupPageContent extends StatefulWidget {
  const _OtpSignupPageContent();

  @override
  State<_OtpSignupPageContent> createState() => _OtpSignupPageContentState();
}

class _OtpSignupPageContentState extends State<_OtpSignupPageContent> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateOtpController(AuthProvider provider) {
    provider.otpController.text = _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.primaryColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.secondaryColor,
                          size: 20,
                        ),
                      ),
                      const Text(
                        'DJINA',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryColor,
                          letterSpacing: 1,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),

                // Contenu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Titre
                        const Text(
                          'VERIFICATION',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppTheme.cardColor,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Numéro de téléphone
                        if (authProvider.pendingPhone != null)
                          Text(
                            'Code envoyé au ${authProvider.pendingPhone}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.secondaryColor,
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Champs OTP (6 chiffres)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 45,
                              height: 50,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryColor,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: AppTheme.primaryColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppTheme.secondaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppTheme.secondaryColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  if (value.length == 1) {
                                    if (index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else {
                                      _focusNodes[index].unfocus();
                                    }
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                  _updateOtpController(authProvider);
                                },
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 32),

                        // Bouton Valider
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            onPressed: authProvider.isOtpLoading
                                ? null
                                : () => authProvider.verifyOtp(context),
                            child: authProvider.isOtpLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Valider',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Timer
                        if (authProvider.otpSecondsRemaining > 0)
                          Center(
                            child: Text(
                              'Expire dans ${authProvider.formattedOtpTime}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Bouton Renvoyer
                        Center(
                          child: GestureDetector(
                            onTap: authProvider.isResendingOtp ||
                                    authProvider.otpSecondsRemaining > 240
                                ? null
                                : () {
                                    for (var controller in _controllers) {
                                      controller.clear();
                                    }
                                    authProvider.resendOtp(context);
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: authProvider.otpSecondsRemaining > 240
                                      ? Colors.grey
                                      : AppTheme.secondaryColor,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: authProvider.isResendingOtp
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Text(
                                      'Renvoyer un autre code OTP',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            authProvider.otpSecondsRemaining >
                                                    240
                                                ? Colors.grey
                                                : AppTheme.secondaryColor,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const Spacer(),
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