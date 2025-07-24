import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';
import 'loginCtrl.dart';
import 'login_state.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginCtrl = ref.watch(loginCtrlProvider.notifier);
    final loginState = ref.watch(loginCtrlProvider);

    ref.listen<LoginState>(loginCtrlProvider, (previous, current) {
      if (!current.isLoading && current.error == null && previous?.isLoading == true) {
        debugPrint("Login successful, navigating to app_home_page");
        getIt<NavigationUtils>().replaceNamed('app_home_page');
      } else if (current.error != null && previous?.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error!),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fond clair
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // Header avec logo
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    children: [
                      // Logo container avec votre couleur orange
                      // Logo container avec votre couleur orange
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF6B00), // Orange de votre logo
                              const Color(0xFFFF8533),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B00).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset( // <-- Changed to Image.asset
                          'assets/orange_logo.png',
                          width: 40,
                          height: 40,

                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Bienvenue',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A), // Texte sombre
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connectez-vous à votre compte',
                        style: TextStyle(
                          color: Colors.grey.shade600, // Gris plus sombre
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Formulaire
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white, // Fond blanc
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: loginState.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32),

                          // Champ Email
                          _buildModernTextField(
                            controller: loginState.emailController,
                            label: 'Adresse email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Veuillez entrer un email valide';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Champ Mot de passe
                          _buildModernTextField(
                            controller: loginState.passwordController,
                            label: 'Mot de passe',
                            icon: Icons.lock_outline,
                            obscureText: !loginState.isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                loginState.isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: loginCtrl.togglePasswordVisibility,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre mot de passe';
                              }
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Se souvenir de moi
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: loginState.rememberMe,
                                  onChanged: loginCtrl.toggleRememberMe,
                                  activeColor: const Color(0xFFFF6B00),
                                  checkColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Se souvenir de moi',
                                style: TextStyle(
                                  color: Colors.grey.shade700, // Gris sombre
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  // Navigation vers mot de passe oublié
                                },
                                child: const Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                    color: Color(0xFFFF6B00),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Bouton de connexion
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 56,
                            child: ElevatedButton(
                              onPressed: loginState.isLoading
                                  ? null
                                  : () => loginCtrl.handleLogin(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B00),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: const Color(0xFFFF6B00).withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ).copyWith(
                                elevation: MaterialStateProperty.resolveWith<double>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed)) {
                                      return 8;
                                    }
                                    return 4;
                                  },
                                ),
                              ),
                              child: loginState.isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : const Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Spacer(),

                          // Inscription
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pas encore de compte ? ',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Naviguer vers la page d'inscription
                                  final navigation = getIt.get<NavigationUtils>();
                                  navigation.goTo('/public/auth/registerPage');
                                },
                                child: const Text(
                                  'S\'inscrire',
                                  style: TextStyle(
                                    color: Color(0xFFFF6B00),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFF1A1A1A), // Texte sombre
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey.shade600,
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50, // Fond très clair
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFF6B00),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        errorStyle: TextStyle(
          color: Colors.red.shade400,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.grey.shade700, // Icône sombre
          size: 20,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700, // Texte sombre
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.grey.shade300, // Bordure claire
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.grey.shade50, // Fond très clair
        ),
      ),
    );
  }
}