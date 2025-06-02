import 'package:flutter/material.dart';

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
    this.labelColor = Colors.black,
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
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.error,
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
    this.backgroundColor = const Color(0xFFFFEDD5), // Orange très clair
    this.textColor = const Color(0xFFEA580C), // Orange principal
    this.borderColor = const Color(0xFFFDBA74), // Orange clair
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
            color: textColor,
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
                color: textColor,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
