import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/registerUser.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/auth/register/registerUserCtrl.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';

class RegisterUserPage extends ConsumerStatefulWidget {
  const RegisterUserPage({super.key});

  @override
  ConsumerState<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends ConsumerState<RegisterUserPage> {
  // Couleurs modernisées
  final Color primaryColor = const Color(0xFF1A1A1A);
  final Color accentColor = const Color(0xFFFF6B35);
  final Color lightBackground = const Color(0xFFF8F9FA);
  final Color inputBackground = Colors.white;
  final Color borderColor = const Color(0xFFE0E0E0);
  final Color hintColor = const Color(0xFF9E9E9E);
  final Color errorColor = const Color(0xFFE53935);
  final Color successColor = const Color(0xFF43A047);

  final _formKey = GlobalKey<FormState>();
  final NavigationUtils navigation = getIt.get<NavigationUtils>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    ref.read(RegisterUserCtrlProvider.notifier).resetMessages();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(RegisterUserCtrlProvider);
    final isSubmited = state.isSubmited;

    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Header
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.account_circle,
                          size: 64,
                          color: accentColor),
                      const SizedBox(height: 16),
                      Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rejoignez notre communauté',
                        style: TextStyle(
                          fontSize: 14,
                          color: hintColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Formulaire
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          // Messages d'état
                          if (state.errorMessage != null)
                            _buildMessageCard(
                              state.errorMessage!,
                              Icons.error_outline,
                              errorColor,
                            ),

                          if (state.successMessage != null)
                            _buildMessageCard(
                              state.successMessage!,
                              Icons.check_circle_outline,
                              successColor,
                            ),

                          const SizedBox(height: 16),

                          // Nom
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: _modernInputDecoration(
                              label: 'Nom complet',
                              hint: 'John Doe',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Veuillez entrer votre nom";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _modernInputDecoration(
                              label: 'Adresse email',
                              hint: 'exemple@mail.com',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Veuillez entrer votre email";
                              }
                              final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                              if (!emailRegex.hasMatch(value.trim())) {
                                return "Email invalide";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Mot de passe
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: _modernPasswordInputDecoration(
                              label: 'Mot de passe',
                              hint: '••••••',
                              obscure: _obscurePassword,
                              onToggle: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Veuillez entrer un mot de passe";
                              }
                              if (value.length < 6) {
                                return "Au moins 6 caractères";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Confirmation mot de passe
                          TextFormField(
                            controller: _confirmPasswordCtrl,
                            obscureText: _obscureConfirmPassword,
                            decoration: _modernPasswordInputDecoration(
                              label: 'Confirmer le mot de passe',
                              hint: '••••••',
                              obscure: _obscureConfirmPassword,
                              onToggle: () {
                                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                            ),
                            validator: (value) {
                              if (value != _passwordCtrl.text) {
                                return "Les mots de passe ne correspondent pas";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Bouton d'inscription
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: state.isSubmited == true
                                  ? null
                                  : () async {
                                FocusScope.of(context).unfocus();

                                if (_formKey.currentState!.validate()) {
                                  final newUser = RegisterUser(
                                    name: _nameCtrl.text.trim(),
                                    email: _emailCtrl.text.trim(),
                                    password: _passwordCtrl.text,
                                    password_confirmation: _confirmPasswordCtrl.text,
                                  );

                                  final result = await ref.read(RegisterUserCtrlProvider.notifier).register(newUser);

                                  if (result == true) {
                                    Future.delayed(const Duration(seconds: 2), (){
                                      navigation.replace('/public/auth/verifyOtp');
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: state.isSubmited == true
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                                  : const Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Lien vers connexion
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Déjà un compte ? ',
                                style: TextStyle(
                                  color: hintColor,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  ref.read(RegisterUserCtrlProvider.notifier).resetMessages();
                                  navigation.replace('/public/auth/loginPage');
                                },
                                child: Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    color: accentColor,
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

  Widget _buildMessageCard(String message, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: color),
            onPressed: () {
              ref.read(RegisterUserCtrlProvider.notifier).resetMessages();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  InputDecoration _modernInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: hintColor),
      labelStyle: TextStyle(color: primaryColor),
      filled: true,
      fillColor: inputBackground,
      prefixIcon: Icon(icon, color: hintColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  InputDecoration _modernPasswordInputDecoration({
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: hintColor),
      labelStyle: TextStyle(color: primaryColor),
      filled: true,
      fillColor: inputBackground,
      prefixIcon: Icon(Icons.lock_outline, color: hintColor),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: hintColor,
        ),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}