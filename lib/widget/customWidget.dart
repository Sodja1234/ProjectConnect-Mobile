import 'package:flutter/material.dart';

// Palette de couleurs
final Color primaryColor = const Color(0xFF1A1A1A);      // Noir pour les titres
final Color accentColor = const Color(0xFFFF6B35);       // Orange principal
final Color lightGray = const Color(0xFFF8F9FA);         // Gris très clair pour les backgrounds
final Color mediumGray = const Color(0xFFE9ECEF);        // Gris moyen pour les bordures
final Color darkGray = const Color(0xFF6C757D);          // Gris foncé pour le texte secondaire
final Color cardBackground = Colors.white;               // Blanc pour les cartes

/// Widget personnalisé pour les champs de formulaire avec label
class FormFields extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isRequired;
  final Color labelColor;

  const FormFields({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.labelColor = const Color(0xFF1A1A1A), // Utilisation du noir primaire par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Widget pour afficher un message d'erreur
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightGray, // Gris très clair pour le fond
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: mediumGray, // Gris moyen pour la bordure
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: accentColor, // Orange principal pour l'icône
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: primaryColor, // Noir pour le texte
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: darkGray, // Gris foncé pour l'icône de fermeture
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget pour afficher un message de succès
class SuccessMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const SuccessMessage({
    super.key,
    required this.message,
    this.onDismiss,
    this.backgroundColor = const Color(0xFFF8F9FA), // lightGray comme const
    this.textColor = const Color(0xFF1A1A1A),      // primaryColor comme const
    this.borderColor = const Color(0xFFFF6B35),   // Orange principal par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: accentColor, // Orange principal pour l'icône
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: darkGray, // Gris foncé pour l'icône de fermeture
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}