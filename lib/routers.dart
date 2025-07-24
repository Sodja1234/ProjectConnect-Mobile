import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:odc_mobile_template/pages/auth/login/login_screen.dart';
import 'package:odc_mobile_template/pages/auth/register/registerUserPage.dart';
import 'package:odc_mobile_template/pages/auth/verifyOtp/verifyOtpPage.dart';
import 'package:odc_mobile_template/pages/createProject/createProjectPage.dart';
import 'package:odc_mobile_template/pages/listProject/listProjectPage.dart';
import 'package:odc_mobile_template/widget/app_shell.dart';
import 'pages/404/not_found_page.dart';
import 'pages/intro/appCtrl.dart';
import 'pages/intro/introPage.dart';
import 'utils/navigationUtils.dart';
import './main.dart';
import 'pages/home/homePage.dart';

final routerConfigProvider = Provider<GoRouter>((ref) {
  final navigatorKey = getIt<NavigationUtils>().navigatorKey;

  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: "/public/login",

    // --- LA CORRECTION EST ICI : Utilisez ref.read au lieu de ref.watch ---
    redirect: (context, state) {
      // Utilisez ref.read pour obtenir l'état actuel de appCtrlProvider sans
      // rendre routerConfigProvider dépendant de appCtrlProvider pour les reconstructions.
      final appState = ref.read(appCtrlProvider); // <<< Changé de ref.watch à ref.read
      final user = appState.user;

      final isAuthenticated = user != null;
      final isGoingToPublicRoute = state.matchedLocation.startsWith("/public");
      final isGoingToAppRoute = state.matchedLocation.startsWith("/app");
      final isGoingToLoginPage = state.matchedLocation == "/public/login";

      print('--- Débogage Redirection (depuis routers.dart) ---');
      print('Chemin actuel : ${state.matchedLocation}');
      print('Est authentifié : $isAuthenticated');
      print('Va vers une route publique : $isGoingToPublicRoute');
      print('Va vers une route d\'application : $isGoingToAppRoute');
      print('Va vers la page de connexion : $isGoingToLoginPage');
      print('Objet utilisateur en redirection : ${user?.email ?? 'null'}'); // Affiche l'e-mail pour plus de clarté

      String? redirectTo;

      // Scénario 1: L'utilisateur est connecté
      if (isAuthenticated) {
        if (isGoingToPublicRoute && !isGoingToLoginPage && !state.matchedLocation.startsWith("/public/intro")) {
          redirectTo = "/app/home"; // Rediriger vers l'accueil de l'app si sur une autre page publique (pas login/intro)
        }
        // else: Si déjà sur une route /app ou sur /public/login ou /public/intro et authentifié, aucune redirection n'est nécessaire.
      }
      // Scénario 2: L'utilisateur n'est PAS connecté
      else {
        if (isGoingToAppRoute && !isGoingToLoginPage) {
          redirectTo = "/public/login"; // Rediriger vers la connexion si tente d'accéder à une route d'application
        }
        // else: Si déjà sur /public/login ou /public/intro et non authentifié, aucune redirection n'est nécessaire.
      }

      print('Redirection vers : $redirectTo');
      print('--------------------------');
      return redirectTo;
    },
    routes: [
      // --- Routes Publiques (sans BottomNavigationBar) ---
      GoRoute(
        path: "/public/intro",
        name: 'intro_page',
        builder: (ctx, state) {
          return IntroPage();
        },
      ),
      GoRoute(
        path: "/public/auth/login",
        name: 'login_page',
        builder: (ctx, state) {
          return LoginPage();
        },
      ),
      GoRoute(
        path: "/public/home",
        name: 'home_page_public',
        builder: (ctx, state) {
          return ListProjectPage();
        },
      ),
      GoRoute(
          path: "/public/auth/registerPage",
          name: "register_page",
          builder: (ctx, state){
            return RegisterUserPage();
          }),
      //route verifyOtp
      GoRoute(
          path: "/public/auth/verifyOtp",
          name: "verify_otp_page",
          builder: (ctx, state){
            return VerifyOtpPage();
          }),

      // --- SHELL ROUTE pour les routes authentifiées (AVEC BottomNavigationBar) ---
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child, currentLocation: state.uri.path);
        },
        routes: [
          GoRoute(
            path: "/app/home",
            name: 'app_home_page',
            builder: (ctx, state) {
              return HomePage();
            },
          ),
          GoRoute(
            path: "/app/projects",
            name: 'app_projects_page',
            builder: (ctx, state) {
              return ListProjectPage();
            },
          ),
          GoRoute(
            path: "/app/create/project",
            name: 'app_create_project_page',
            builder: (ctx, state) {
              return ProjectFormPage();
            },
          ),
          GoRoute(
            path: "/app/notifications",
            name: 'app_notifications_page',
            builder: (ctx, state) {
              return const Center(child: Text('Page de Notifications (à créer)'));
            },
          ),
          GoRoute(
            path: "/app/jobs",
            name: 'app_jobs_page',
            builder: (ctx, state) {
              return const Center(child: Text('Page d\'Emplois (à créer)'));
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});