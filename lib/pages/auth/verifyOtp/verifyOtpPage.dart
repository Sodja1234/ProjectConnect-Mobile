import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/auth/register/registerUserCtrl.dart';
import 'package:odc_mobile_template/pages/auth/verifyOtp/verifyOtpCtrl.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';
import '../../../business/models/user/verifyOtp.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  final String? email;
  const VerifyOtpPage({super.key, this.email});

  @override
  ConsumerState<VerifyOtpPage> createState() => _OtpValidationPageState();
}

class _OtpValidationPageState extends ConsumerState<VerifyOtpPage> {
  // Couleurs harmonisées avec RegisterUserPage
  final Color primaryColor = const Color(0xFF1A1A1A);
  final Color accentColor = const Color(0xFFFF6B35);
  final Color lightBackground = const Color(0xFFF8F9FA);
  final Color inputBackground = Colors.white;
  final Color borderColor = const Color(0xFFE0E0E0);
  final Color hintColor = const Color(0xFF9E9E9E);
  final Color errorColor = const Color(0xFFE53935);
  final Color successColor = const Color(0xFF43A047);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyOtpCtrlProvider);
    final navigation = getIt.get<NavigationUtils>();
    final registerState = ref.watch(RegisterUserCtrlProvider);
    final _email = widget.email ?? registerState.email;

    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header avec icône
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.verified_user, size: 64, color: accentColor),
                      const SizedBox(height: 16),
                      Text(
                        'Vérification OTP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entrez le code reçu par email',
                        style: TextStyle(
                          fontSize: 14,
                          color: hintColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Carte du formulaire
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
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

                          // Information email
                          Text(
                            'Code envoyé à',
                            style: TextStyle(
                              color: hintColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _email!,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Champ OTP
                          TextFormField(
                            controller: _otpCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _modernInputDecoration(
                              label: 'Code OTP',
                              hint: '123456',
                              icon: Icons.lock_clock_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Le code est requis";
                              }
                              if (value.length != 6) {
                                return "Le code doit contenir 6 chiffres";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Bouton de vérification
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: state.isSubmited == true
                                  ? null
                                  : () async {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate()) {
                                  final user = VerifyOtp(
                                      email: _email, otp: _otpCtrl.text);

                                  final result = await ref
                                      .read(verifyOtpCtrlProvider.notifier)
                                      .verifyOtp(user);

                                  if (result == true && mounted) {
                                    navigation.replace('/public/home');
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
                                'Vérifier',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Lien pour renvoyer le code
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Pas reçu le code ? ",
                                style: TextStyle(
                                  color: hintColor,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final user = VerifyOtp(email: _email);
                                  await ref
                                      .read(verifyOtpCtrlProvider.notifier)
                                      .resendOtp(user);
                                },
                                child: Text(
                                  'Renvoyer',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Lien vers la page de connexion
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Email déjà vérifié ? ",
                                style: TextStyle(
                                  color: hintColor,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  navigation.replace('/public/auth/login');
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
          border: Border.all(color: color.withOpacity(0.3))),
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
              ref.read(verifyOtpCtrlProvider.notifier).resetMessages();
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
}