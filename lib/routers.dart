import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:odc_mobile_template/pages/auth/register/registerUserPage.dart';
import 'package:odc_mobile_template/pages/auth/verifyOtp/verifyOtpPage.dart';
import 'package:odc_mobile_template/pages/createProject/createProjectPage.dart';
import 'package:odc_mobile_template/pages/listProject/listProjectPage.dart';
import 'pages/404/not_found_page.dart';
import 'pages/intro/appCtrl.dart';
import 'pages/intro/introPage.dart';
import 'utils/navigationUtils.dart';
import './main.dart';
import 'pages/home/homePage.dart';
import 'pages/login/login_screen.dart';

final routerConfigProvider = Provider<GoRouter>((ref) {
  final navigatorKey = getIt<NavigationUtils>().navigatorKey;
  /*
   routes restreintes
  */
  final authRoutes = [
    GoRoute(
      path: "/public/create/project",
      name: 'create_project_page',
      builder: (ctx, state) {
        return ProjectFormPage();
      },
    ),


  ];

  /*
   routes publics
  */
  final noAuthRoutes = [
    GoRoute(
      path: "/public/intro",
      name: 'intro_page',
      builder: (ctx, state) {
        return IntroPage();
      },
    ),
    GoRoute(
      path: "/public/login",
      name: 'login_page',
      builder: (ctx, state) {
        return LoginPage();
      },
    ),

    GoRoute(
      path: "/public/home",
      name: 'home_page',
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


  ];

  /*
CONFIGURATION  DES ROUTES
*/
  return GoRouter(
  navigatorKey: navigatorKey,
  debugLogDiagnostics: true,
  initialLocation: "/public/login", // <-- C'est ici que nous changeons la page de démarrage
  redirect: (context, state) {
  var appState = ref.watch(appCtrlProvider);
  var user = appState.user;

  // Si l'utilisateur est connecté et essaie d'accéder à une route publique (comme login ou intro),
  // redirigez-le vers la page d'accueil de l'application.
  if (user != null && state.matchedLocation.startsWith("/public")) {
  return "/app/home";
  }

  // Si l'utilisateur n'est PAS connecté et essaie d'accéder à une route authentifiée ('/app'),
  // redirigez-le vers la page de connexion, SAUF s'il est déjà sur la page de connexion.
  if (user == null && state.matchedLocation.startsWith("/app")) {
  if (state.matchedLocation != "/public/login") { // Éviter la boucle de redirection
  return "/public/login";
  }
  }

  return null; // Pas de redirection nécessaire
  },
  routes: [...noAuthRoutes, ...authRoutes],
  errorBuilder: (context, state) => const NotFoundPage(),
  );
});