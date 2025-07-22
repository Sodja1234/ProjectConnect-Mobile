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
    final loginController = ref.watch(loginCtrlProvider.notifier);
    final loginState = ref.watch(loginCtrlProvider);

    ref.listen<LoginState>(loginCtrlProvider, (previousState, newState) {
      if (previousState?.isLoading == true && !newState.isLoading && newState.error == null) {
        // Naviguer vers la HomePage après une connexion réussie
        getIt<NavigationUtils>().replaceNamed('home_page'); // Utilisez le nom de votre route HomePage
      }

      if (newState.error != null && newState.error != previousState?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newState.error!)),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: loginState.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: loginState.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: loginState.passwordController,
                obscureText: !loginState.isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      loginState.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: loginController.togglePasswordVisibility,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Checkbox(
                    value: loginState.rememberMe,
                    onChanged: loginController.toggleRememberMe,
                  ),
                  const Text('Se souvenir de moi'),
                ],
              ),
              const SizedBox(height: 24.0),
              loginState.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: loginController.handleLogin,
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  // TODO: Naviguer vers la page d'inscription si vous avez une route 'registerRoute'
                  // getIt<NavigationUtils>().navigateNamed('registerRoute');
                },
                child: const Text('Pas encore de compte ? S\'inscrire'),
              ),
              if (loginState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    loginState.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}