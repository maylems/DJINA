import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/auth/auth_repository.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/sweet_alert.dart';
import '../navigation/auth_navigation.dart';
import '../pages/login_page.dart';
import 'package:djina_debug/config/route_pages.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final TokenStorage _tokenStorage = TokenStorage();

  bool _isLoginLoading = false;
  bool _isSignupLoading = false;
  bool _isOtpLoading = false;
  bool _isResendingOtp = false;

  bool _obscurePassword = true;
  bool _acceptTerms = false;

  final TextEditingController _emailLoginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _errorMessage;
  String? _successMessage;
  UserModel? _currentUser;
  String? _pendingPhone;

  Timer? _otpTimer;
  int _otpSecondsRemaining = 300;

  AuthProvider() {
    _emailLoginController.addListener(_onTextChanged);
    _passwordController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
    _firstNameController.addListener(_onTextChanged);
    _lastNameController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
    _referralCodeController.addListener(_onTextChanged);
    _otpController.addListener(_onTextChanged);
  }

  void _onTextChanged() => notifyListeners();

  // ── Getters ──────────────────────────────────────────────────────────────

  bool get isLoginLoading => _isLoginLoading;
  bool get isSignupLoading => _isSignupLoading;
  bool get isOtpLoading => _isOtpLoading;
  bool get isResendingOtp => _isResendingOtp;
  bool get obscurePassword => _obscurePassword;
  bool get acceptTerms => _acceptTerms;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get currentUser => _currentUser;
  String? get pendingPhone => _pendingPhone;
  int get otpSecondsRemaining => _otpSecondsRemaining;

  TextEditingController get emailLoginController => _emailLoginController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get referralCodeController => _referralCodeController;
  TextEditingController get otpController => _otpController;

  bool get isLoginFormValid =>
      _emailLoginController.text.trim().isNotEmpty &&
      _emailLoginController.text.contains('@') &&
      _passwordController.text.isNotEmpty;

  bool get isSignupFormValid =>
      _phoneController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _acceptTerms;

  bool get isOtpFormValid => _otpController.text.length >= 6;

  String get formattedOtpTime {
    final minutes = _otpSecondsRemaining ~/ 60;
    final seconds = _otpSecondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleTermsAcceptance() {
    _acceptTerms = !_acceptTerms;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Connexion ────────────────────────────────────────────────────────────

  Future<void> login(BuildContext context) async {
  if (!isLoginFormValid) {
    SweetAlert.error(
        context, 'Veuillez saisir un email et un mot de passe valides');
    return;
  }

  _isLoginLoading = true;
  clearError();
  notifyListeners();

  try {
    final result = await _authRepository.login(
      email: _emailLoginController.text.trim(),
      password: _passwordController.text,
    );

    if (result['success'] == true) {
      // ✅ Nouveau format : données dans result['data']
      final data = result['data'];
      if (data is Map<String, dynamic> && data['user'] != null) {
        _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        // Fallback : appel API /auth/me/
        _currentUser = await _authRepository.getCurrentUser();
      }
      notifyListeners();

      if (context.mounted) {
        SweetAlert.success(context, 'Connexion réussie !');
        await Future.delayed(const Duration(milliseconds: 500));
        AuthNavigation.completeAuthentication(context);
      }
    } else {
      if (context.mounted) {
        SweetAlert.error(
            context, result['message'] ?? 'Email ou mot de passe incorrect.');
      }
    }
  } catch (e) {
    if (context.mounted) SweetAlert.error(context, 'Une erreur est survenue');
  } finally {
    _isLoginLoading = false;
    notifyListeners();
  }
}
  // ── Inscription ──────────────────────────────────────────────────────────

  Future<void> signup(
    BuildContext context, {
    required void Function(String phone) onSuccess,
  }) async {
    if (!isSignupFormValid) {
      if (!_acceptTerms) {
        SweetAlert.warning(
            context, 'Vous devez accepter les conditions générales');
      } else {
        SweetAlert.error(
            context, 'Veuillez remplir tous les champs obligatoires');
      }
      return;
    }

    _isSignupLoading = true;
    clearError();
    notifyListeners();

    try {
      final phone = '+221${_phoneController.text.trim()}';
      final email = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : '${_phoneController.text.trim()}@djina.app';

      final result = await _authRepository.registerCustomer(
        email: email,
        phone: phone,
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        referralCode: _referralCodeController.text.trim().isNotEmpty
            ? _referralCodeController.text.trim()
            : null,
      );

      if (result['success'] == true) {
        _pendingPhone = phone;
        await requestOtp(phone);

        if (context.mounted) {
          SweetAlert.success(
            context,
            'Un code de vérification a été envoyé au $phone',
            title: 'Inscription réussie',
          );
          await Future.delayed(const Duration(milliseconds: 800));
          onSuccess(phone);
        }
      } else {
        if (context.mounted) {
          SweetAlert.error(
              context, result['message'] ?? 'Erreur d\'inscription');
        }
      }
    } catch (e) {
      if (context.mounted) SweetAlert.error(context, 'Une erreur est survenue');
    } finally {
      _isSignupLoading = false;
      notifyListeners();
    }
  }

  // ── OTP ──────────────────────────────────────────────────────────────────

  Future<void> requestOtp(String phone) async {
    _isOtpLoading = true;
    clearError();
    notifyListeners();

    try {
      final result = await _authRepository.requestOtp(phone);
      if (result['success'] == true) {
        _pendingPhone = phone;
        _startOtpTimer();
        setSuccess(result['message'] ?? 'Code OTP envoyé');
      } else {
        setError(result['message'] ?? 'Erreur d\'envoi OTP');
      }
    } catch (e) {
      setError('Une erreur est survenue');
    } finally {
      _isOtpLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (!isOtpFormValid) {
      SweetAlert.warning(context, 'Veuillez saisir le code complet');
      return;
    }
    if (_pendingPhone == null) {
      SweetAlert.error(context, 'Numéro de téléphone manquant');
      return;
    }

    _isOtpLoading = true;
    clearError();
    notifyListeners();

    try {
      final verifiedPhone = _pendingPhone!;
      final result = await _authRepository.verifyOtp(
        phone: verifiedPhone,
        code: _otpController.text,
      );

      if (result['success'] == true) {
        _stopOtpTimer();
        final savedEmail = await _tokenStorage.getEmail();
        resetOtpForm();

        if (context.mounted) {
          SweetAlert.success(
            context,
            'Compte vérifié ! Connectez-vous pour continuer.',
            title: 'Vérification réussie ✓',
          );
          await Future.delayed(const Duration(milliseconds: 1000));

          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => LoginPage(prefillEmail: savedEmail),
              ),
              (route) => false,
            );
          }
        }
      } else {
        if (context.mounted) {
          SweetAlert.error(context, result['message'] ?? 'Code invalide');
        }
      }
    } catch (e) {
      if (context.mounted) SweetAlert.error(context, 'Une erreur est survenue');
    } finally {
      _isOtpLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithOtp(BuildContext context) async {
  if (!isOtpFormValid || _pendingPhone == null) return;

  _isOtpLoading = true;
  clearError();
  notifyListeners();

  try {
    final result = await _authRepository.loginWithOtp(
      phone: _pendingPhone!,
      code: _otpController.text,
    );

    if (result['success'] == true) {
      _stopOtpTimer();

      // ✅ Nouveau format : données dans result['data']
      final data = result['data'];
      if (data is Map<String, dynamic> && data['user'] != null) {
        _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        await _loadCurrentUser();
      }

      if (context.mounted) AuthNavigation.completeAuthentication(context);
    } else {
      if (context.mounted) {
        SweetAlert.error(context, result['message'] ?? 'Code invalide');
      }
    }
  } catch (e) {
    if (context.mounted) SweetAlert.error(context, 'Une erreur est survenue');
  } finally {
    _isOtpLoading = false;
    notifyListeners();
  }
}
  Future<void> resendOtp(BuildContext context) async {
    if (_pendingPhone == null) return;
    _isResendingOtp = true;
    clearError();
    notifyListeners();

    try {
      await requestOtp(_pendingPhone!);
      if (context.mounted) {
        SweetAlert.success(context, 'Un nouveau code a été envoyé');
      }
    } catch (e) {
      if (context.mounted) SweetAlert.error(context, 'Erreur lors du renvoi');
    } finally {
      _isResendingOtp = false;
      notifyListeners();
    }
  }

  // ── Timer OTP ────────────────────────────────────────────────────────────

  void _startOtpTimer({int seconds = 300}) {
    _stopOtpTimer();
    _otpSecondsRemaining = seconds;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpSecondsRemaining > 0) {
        _otpSecondsRemaining--;
        notifyListeners();
      } else {
        _stopOtpTimer();
      }
    });
  }

  void _stopOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
  }

  // ── Session ──────────────────────────────────────────────────────────────

  /// Vérifie uniquement la présence du token (pas de requête réseau).
  /// Utilisé par MainPage pour le routage initial.
  Future<bool> hasActiveToken() async {
    return _tokenStorage.isAuthenticated();
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authRepository.getCurrentUser();
      notifyListeners();
    } catch (_) {}
  }

  /// Vérifie le token et charge l'user si absent.
  /// Utilisé par HomePage au démarrage.
  Future<bool> checkAuthentication() async {
    final isAuth = await _tokenStorage.isAuthenticated();
    if (isAuth && _currentUser == null) {
      await _loadCurrentUser();
    }
    return isAuth;
  }

  // ── Déconnexion ──────────────────────────────────────────────────────────

  /// Déconnexion depuis un BuildContext normal (hors drawer).
  Future<void> logout(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    await _performLogout(navigator);
  }

  /// ✅ Déconnexion depuis le drawer :
  /// reçoit le NavigatorState capturé AVANT la fermeture du drawer,
  /// donc jamais invalidé même après Navigator.pop().
  Future<void> logoutWithNavigator(NavigatorState navigator) async {
    await _performLogout(navigator);
  }

  /// Logique commune : efface les données puis vide la pile vers JoinLogin.
  Future<void> _performLogout(NavigatorState navigator) async {
    // Confirmation
    final confirmed = await showDialog<bool>(
      context: navigator.context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content:
            const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Oui',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Efface tokens + état local
    await _authRepository.logout();
    _currentUser = null;
    resetAllForms();
    notifyListeners();

    // ✅ pushNamedAndRemoveUntil vide toute la pile (routes nommées incluses)
    navigator.pushNamedAndRemoveUntil(
      RoutePages.joinLogin,
      (route) => false,
    );
  }

  /// Déconnexion silencieuse sans navigation (expiration de token).
  Future<void> silentLogout() async {
    await _authRepository.logout();
    _currentUser = null;
    resetAllForms();
    notifyListeners();
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  void resetLoginForm() {
    _emailLoginController.clear();
    _passwordController.clear();
    _obscurePassword = true;
    clearError();
  }

  void resetSignupForm() {
    _phoneController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _referralCodeController.clear();
    _obscurePassword = true;
    _acceptTerms = false;
    clearError();
  }

  void resetOtpForm() {
    _otpController.clear();
    _pendingPhone = null;
    _stopOtpTimer();
    clearError();
  }

  void resetAllForms() {
    resetLoginForm();
    resetSignupForm();
    resetOtpForm();
  }

  @override
  void dispose() {
    _emailLoginController.removeListener(_onTextChanged);
    _passwordController.removeListener(_onTextChanged);
    _phoneController.removeListener(_onTextChanged);
    _firstNameController.removeListener(_onTextChanged);
    _lastNameController.removeListener(_onTextChanged);
    _emailController.removeListener(_onTextChanged);
    _referralCodeController.removeListener(_onTextChanged);
    _otpController.removeListener(_onTextChanged);

    _emailLoginController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _referralCodeController.dispose();
    _otpController.dispose();

    _stopOtpTimer();
    super.dispose();
  }
}