// lib/routers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Importe toutes tes pages nécessaires
import 'package:odc_mobile_template/pages/auth/login/login_screen.dart';
import 'package:odc_mobile_template/pages/auth/register/registerUserPage.dart';
import 'package:odc_mobile_template/pages/auth/verifyOtp/verifyOtpPage.dart';
import 'package:odc_mobile_template/pages/createProject/createProjectPage.dart';
//import 'package:odc_mobile_template/pages/createProject/createProjectPage.dart'; // Nommé ProjectFormPage dans ton routeur
import 'package:odc_mobile_template/pages/intro/appState.dart';
import 'package:odc_mobile_template/pages/listProject/listProjectPage.dart';
import 'package:odc_mobile_template/pages/profil/profil_screen.dart';
import 'package:odc_mobile_template/pages/singleProject/singleProjectPage.dart';
import 'package:odc_mobile_template/widget/app_shell.dart';
import 'pages/404/not_found_page.dart';
import 'pages/intro/appCtrl.dart';
import 'pages/intro/introPage.dart';
import 'utils/navigationUtils.dart';
import './main.dart'; // Pour getIt
import 'pages/home/homePage.dart';

final routerConfigProvider = Provider<GoRouter>((ref) {
  final navigatorKey = getIt<NavigationUtils>().navigatorKey;

  // Utilise le notifier pour accéder à isAuthenticatedNotifier
  final AppCtrl appController = ref.watch(appCtrlProvider.notifier);
  final AppState appState = ref.watch(appCtrlProvider); // Pour les logs de débogage ou l'accès direct à user/token

  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: "/public/auth/login", // Démarre toujours à la page d'accueil publique

    // Écoute les changements d'état d'authentification SANS reconstruire le GoRouter entier
    refreshListenable: appController.isAuthenticatedNotifier,

    redirect: (context, state) {
      final isAuthenticated = appController.isAuthenticatedNotifier.value;
      // Note: appState.userToken est la source de vérité pour isAuthenticatedNotifier.value
      // Donc, utiliser appController.isAuthenticatedNotifier.value est le plus direct.

      final isGoingToPublicRoute = state.matchedLocation.startsWith("/public");
      final isGoingToAppRoute = state.matchedLocation.startsWith("/app");
      final isGoingToLoginPage = state.matchedLocation == "/public/auth/login";
      final isGoingToRoot = state.matchedLocation == "/";
      final isGoingToIntro = state.matchedLocation == "/public/intro";


      print('--- Débogage Redirection (depuis routers.dart) ---');
      print('Chemin actuel : ${state.matchedLocation}');
      print('Est authentifié : $isAuthenticated');
      print('Va vers une route publique : $isGoingToPublicRoute');
      print('Va vers une route d\'application : $isGoingToAppRoute');
      print('Va vers la page de connexion : $isGoingToLoginPage');
      print('Va vers la page d\'intro : $isGoingToIntro');
      print('Va vers la racine : $isGoingToRoot');
      print('Objet utilisateur en redirection : ${appState.user?.email ?? 'null'} (token: ${appState.userToken != null && appState.userToken!.isNotEmpty ? 'present' : 'null'})');

      String? redirectTo;

      // Logique de redirection principale
      if (isAuthenticated) {
        // Si l'utilisateur est connecté et tente d'accéder à des routes publiques sensibles
        if (isGoingToLoginPage || isGoingToIntro || isGoingToRoot) {
          redirectTo = "/app/home"; // Rediriger vers la page d'accueil de l'application
        }
        // Sinon, si authentifié et sur une route /app ou une autre route publique non sensible, aucune redirection.
      } else { // Utilisateur non connecté
        // Si l'utilisateur non connecté essaie d'accéder à une route authentifiée
        if (isGoingToAppRoute) {
          redirectTo = "/public/auth/login"; // Rediriger vers la page de connexion
        }
        // Si l'utilisateur non connecté est sur la page d'intro ou la page de connexion ou la page d'accueil publique,
        // aucune redirection n'est nécessaire car il est déjà au bon endroit.
      }

      print('Redirection vers : $redirectTo');
      print('--------------------------');
      return redirectTo;
    },
    routes: [
      // Route pour la racine (redirection vers la page d'accueil publique)
      GoRoute(
        path: '/',
        redirect: (context, state) => '/public/home', // Redirige toujours vers l'accueil public par défaut
      ),
      // --- Routes Publiques (pas de BottomNavigationBar, accès public) ---
      GoRoute(
        path: "/public/intro", // Page d'introduction optionnelle
        name: 'intro_page',
        builder: (ctx, state) => const IntroPage(),
      ),
      GoRoute(
        path: "/public/auth/login",
        name: 'login_page',
        builder: (ctx, state) => const LoginPage(),
      ),
      GoRoute(
        path: "/public/home", // Page d'accueil publique (ListProjectPage)
        name: 'home_page_public',
        builder: (ctx, state) => const ListProjectPage(), // Montre les projets pour tous
      ),
      GoRoute(
        path: "/public/projects/:slug", // Détails d'un projet public
        name: 'public_project_details',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return SingleProjectPage(slug: slug); // Assure-toi d'avoir cette page
        },
      ),
      GoRoute(
        path: "/public/auth/registerPage",
        name: "register_page",
        builder: (ctx, state) => const RegisterUserPage(),
      ),
      GoRoute(
        path: "/public/auth/verifyOtp",
        name: "verify_otp_page",
        builder: (ctx, state) => const VerifyOtpPage(),
      ),

      // --- SHELL ROUTE pour les routes authentifiées (AVEC BottomNavigationBar) ---
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child, currentLocation: state.uri.path);
        },
        routes: [
          GoRoute(
            path: "/app/home", // Page d'accueil de l'application (peut être la même que publique mais avec nav bar)
            name: 'app_home_page',
            builder: (ctx, state) => const HomePage(), // Ou ListProjectPage() si c'est la même
          ),
          GoRoute(
            path: "/app/projects", // Liste des projets authentifiée
            name: 'app_projects_page',
            builder: (ctx, state) => const ListProjectPage(),
          ),
          GoRoute(
            path: "/app/projects/:slug", // Détails d'un projet authentifié
            name: 'app_project_details',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return SingleProjectPage(slug: slug); // Assure-toi d'avoir cette page
            },
          ),
          GoRoute(
            path: "/app/create/project", // Création de projet (protégée)
            name: 'app_create_project_page',
            builder: (ctx, state) => const ProjectFormPage(), // Assure-toi que c'est ProjectFormPage ou CreateProjectPage
          ),
          GoRoute(
            path: "/app/notifications",
            name: 'app_notifications_page',
            builder: (ctx, state) => const Center(child: Text('Page de Notifications (à créer)')),
          ),
          GoRoute(
            path: "/app/jobs",
            name: 'app_jobs_page',
            builder: (ctx, state) => const Center(child: Text('Page d\'Emplois (à créer)')),
          ),
          GoRoute(
            path: "/app/profil",
            name: 'app_profile_page',
            builder: (ctx, state) {
              final user = appState.user; // Accède directement à user via appState

              if (user == null) {
                // Si l'utilisateur est null ici, c'est une situation inattendue pour une route protégée.
                // Redirige vers la connexion et affiche un indicateur temporaire.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  GoRouter.of(ctx).go('/public/auth/login');
                });
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              // Assure-toi que ProfilePage prend un User et un String token (ou juste User)
              return ProfilePage(user: user, userToken: appState.userToken ?? ''); // Passe le token si nécessaire
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});

