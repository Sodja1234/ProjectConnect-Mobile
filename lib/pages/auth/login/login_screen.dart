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
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header avec logo
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: constraints.maxWidth > 600 ? 60 : 24,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B00),
                                    Color(0xFFFF8533),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Image.asset(
                                'assets/orange_logo.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Bienvenue',
                              style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Connectez-vous à votre compte',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                      // Formulaire
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth > 600 ? 60 : 24,
                            vertical: 24,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32)),
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
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Se souvenir de moi',
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 15),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(
                                            color: Color(0xFFFF6B00),
                                            fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Bouton de connexion
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: loginState.isLoading
                                        ? null
                                        : () => loginCtrl.handleLogin(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6B00),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: loginState.isLoading
                                        ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    )
                                        : const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),
                                const Spacer(),

                                // Inscription
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Pas encore de compte ? ',
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 15),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          getIt<NavigationUtils>()
                                              .goTo('/public/auth/registerPage');
                                        },
                                        child: const Text(
                                          'S\'inscrire',
                                          style: TextStyle(
                                              color: Color(0xFFFF6B00),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
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
            );
          },
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),
    );
  }
}