// lib/pages/intro/introPage.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Importation nécessaire pour GoRouter
import '../../main.dart';
import '../../utils/navigationUtils.dart';
import 'appCtrl.dart';
import 'appState.dart';

class IntroPage extends ConsumerStatefulWidget {
  const IntroPage({super.key});

  @override
  ConsumerState<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends ConsumerState<IntroPage> {
  var navigation = getIt<NavigationUtils>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      ref.listen<AppState>(appCtrlProvider, (previousState, newState) {
        // Si l'utilisateur est chargé (authentifié) et qu'on n'est pas déjà redirigé
        if (newState.user != null && newState.userToken != null && newState.userToken!.isNotEmpty) {
          // Navigue vers la page d'accueil de l'application
          GoRouter.of(context).replace('/app/home');
        } else {
          // Sinon (pas d'utilisateur ou pas de token), navigue vers la page de connexion
          GoRouter.of(context).replace('/public/auth/login');
        }
      });
    });
  }

  @override
  void dispose() {
    // Il n'est généralement pas nécessaire de disposer des contrôleurs Riverpod ici,
    // Riverpod gère leur cycle de vie.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/orange_logo.png', width: 100, height: 100, fit: BoxFit.contain),
            const SizedBox(height: 20),
            const Text('Bienvenue sur l\'application ODC'),
            const SizedBox(height: 80),
            const CircularProgressIndicator(color: Colors.orange),
          ],
        ),
      ),
    );
  }
}