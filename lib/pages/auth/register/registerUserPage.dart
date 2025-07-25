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
  final _formKey = GlobalKey<FormState>();
  late final NavigationUtils navigation;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    navigation = getIt.get<NavigationUtils>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(RegisterUserCtrlProvider.notifier).resetMessages();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(RegisterUserCtrlProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

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
                          vertical: isLargeScreen ? 60 : 40,
                          horizontal: isLargeScreen ? 80 : 24,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: isLargeScreen ? 100 : 80,
                              height: isLargeScreen ? 100 : 80,
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
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6B00).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/orange_logo.png',
                                width: isLargeScreen ? 50 : 40,
                                height: isLargeScreen ? 50 : 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Créer un compte',
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rejoignez notre communauté',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Formulaire
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 80 : 24,
                            vertical: isLargeScreen ? 40 : 24,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isLargeScreen ? 500 : double.infinity,
                              ),
                              child: Form(
                                key: _formKey,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 16),

                                    // Messages d'état
                                    if (state.errorMessage != null)
                                      _buildMessageCard(
                                        state.errorMessage!,
                                        Icons.error_outline,
                                        Colors.red.shade600,
                                        true,
                                      ),
                                    if (state.successMessage != null)
                                      _buildMessageCard(
                                        state.successMessage!,
                                        Icons.check_circle_outline,
                                        Colors.green.shade600,
                                        false,
                                      ),

                                    // Champ Nom
                                    _buildModernTextField(
                                      controller: _nameCtrl,
                                      label: 'Nom complet',
                                      icon: Icons.person_outline,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Veuillez entrer votre nom';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Champ Email
                                    _buildModernTextField(
                                      controller: _emailCtrl,
                                      label: 'Adresse email',
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Veuillez entrer votre email';
                                        }
                                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                          return 'Veuillez entrer un email valide';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Champ Mot de passe
                                    _buildModernTextField(
                                      controller: _passwordCtrl,
                                      label: 'Mot de passe',
                                      icon: Icons.lock_outline,
                                      obscureText: _obscurePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () {
                                          setState(() => _obscurePassword = !_obscurePassword);
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Veuillez entrer un mot de passe';
                                        }
                                        if (value.length < 6) {
                                          return 'Le mot de passe doit contenir au moins 6 caractères';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Champ Confirmation mot de passe
                                    _buildModernTextField(
                                      controller: _confirmPasswordCtrl,
                                      label: 'Confirmer le mot de passe',
                                      icon: Icons.lock_outline,
                                      obscureText: _obscureConfirmPassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () {
                                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                        },
                                      ),
                                      validator: (value) {
                                        if (value != _passwordCtrl.text) {
                                          return 'Les mots de passe ne correspondent pas';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 32),

                                    // Bouton d'inscription
                                    SizedBox(
                                      height: 56,
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
                                            final result = await ref
                                                .read(RegisterUserCtrlProvider.notifier)
                                                .register(newUser);
                                            if (result == true) {
                                              Future.delayed(const Duration(seconds: 2), () {
                                                navigation.replace('/public/auth/verifyOtp');
                                              });
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF6B00),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: state.isSubmited == true
                                            ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
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
                                    const Spacer(),

                                    // Lien vers connexion
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Déjà un compte ? ',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref.read(RegisterUserCtrlProvider.notifier).resetMessages();
                                            navigation.replace('/public/login');
                                          },
                                          child: const Text(
                                            'Se connecter',
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

  Widget _buildMessageCard(String message, IconData icon, Color color, bool isError) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isError)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: color),
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
        color: Color(0xFF1A1A1A),
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
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
      ),
    );
  }
}