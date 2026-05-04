import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

/// Utilitaire pour afficher des messages élégants (Sweet Alert style)
/// Utilise awesome_snackbar_content pour des notifications visuelles
class SweetAlert {
  /// Afficher un message de succès
  static void success(
    BuildContext context,
    String message, {
    String title = 'Succès',
  }) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      contentType: ContentType.success,
    );
  }

  /// Afficher un message d'erreur
  static void error(
    BuildContext context,
    String message, {
    String title = 'Erreur',
  }) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  /// Afficher un message d'avertissement
  static void warning(
    BuildContext context,
    String message, {
    String title = 'Attention',
  }) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      contentType: ContentType.warning,
    );
  }

  /// Afficher un message d'information
  static void info(
    BuildContext context,
    String message, {
    String title = 'Information',
  }) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      contentType: ContentType.help,
    );
  }

  /// Fonction privée pour afficher le SnackBar
  static void _showSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Dialog de confirmation (oui/non)
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    cancelText,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(confirmText),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Loading dialog
  static void showLoading(
    BuildContext context, {
    String message = 'Chargement...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Flexible(child: Text(message)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Fermer le loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}