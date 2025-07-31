// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

// Importez les services et utilitaires mis à jour
import 'package:odc_mobile_template/business/services/domain/domainNetworkService.dart';
import 'package:odc_mobile_template/business/services/project/projectNetworkService.dart';
import 'package:odc_mobile_template/business/services/role/roleNetworkService.dart';
import 'package:odc_mobile_template/business/services/skill/skillNetworkService.dart';
import 'package:odc_mobile_template/framework/domain/domainNetworkServiceImpl.dart';
import 'package:odc_mobile_template/framework/project/projectNetworkServiceImpl.dart';
import 'package:odc_mobile_template/framework/role/roleNetworkServiceImpl.dart';
import 'package:odc_mobile_template/framework/skill/skillNetworkServiceImpl.dart';

// Utilise getStorageImpl.dart qui est ton LocalManager implémenté
import 'package:odc_mobile_template/framework/utils/localStorage/getStorageImpl.dart';
import 'package:odc_mobile_template/utils/http/HttpUtils.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';
import 'package:odc_mobile_template/utils/localManager.dart'; // <-- Importe l'interface LocalManager
import 'business/services/gestion/gestionLocalService.dart';
import 'business/services/gestion/gestionNetworkService.dart';
import 'MonApplication.dart';
import 'business/services/user/profil/user_profil_network_service.dart';
import 'business/services/user/userNetworkService.dart';
import 'framework/gestion/gestionNetworkServiceImpl.dart';
import 'framework/gestion/gestionLocalServiceImpl.dart';

import 'framework/user/profil/user_network_service_impl.dart';
import 'framework/user/userNetworkServiceImpl.dart';
import 'framework/utils/http/remoteHttpUtils.dart';
import 'routers.dart';

// NOUVEAUX IMPORTS POUR UserProfilNetworkService

GetIt getIt = GetIt.instance;

// Configuration des instances et injection de dépendances
void configureImplementations() {
  // Enregistrement des HttpUtils
  var httpUtils = RemoteHttpUtils();
  getIt.registerLazySingleton<HttpUtils>(() => httpUtils);

  // Initialisation et enregistrement du LocalManager (GetStorageImpl)
  var localManager = GetStorageImpl();
  getIt.registerLazySingleton<LocalManager>(() => localManager);

  // Récupération de l'URL de base depuis .env
  var baseUrl = dotenv.env['BASE_URL'] ?? '';
  if (baseUrl.isEmpty) {
    print('WARNING: BASE_URL environment variable is not set. Please check your .env file.');
  }

  // Enregistrement des autres services
  getIt.registerLazySingleton<NavigationUtils>(() => NavigationUtils());

  // Services de gestion
  getIt.registerLazySingleton<GestionNetworkService>(() => GestionNetworkServiceImpl(baseUrl: baseUrl, httpUtils: getIt<HttpUtils>()));
  getIt.registerLazySingleton<GestionLocalService>(() => GestionLocalServiceImpl());

  // Service utilisateur (network)
  getIt.registerLazySingleton<UserNetworkService>(() => UserNetworkServiceImpl(baseUrl: baseUrl, httpUtils: getIt<HttpUtils>()));

  // NOUVEL ENREGISTREMENT : UserProfilNetworkService
  getIt.registerLazySingleton<UserProfilNetworkService>(() => UserProfilNetworkServiceImpl(baseUrl: baseUrl, httpUtils: getIt<HttpUtils>()));


  // Services de projet, domaine, rôle, compétence
  getIt.registerLazySingleton<ProjectNetworkService>(() => ProjectNetworkServiceImpl(baseUrl: baseUrl, httpUtils: getIt<HttpUtils>()));
  getIt.registerLazySingleton<DomainNetworkService>(() => DomainNetworkServiceImpl(baseUrl: baseUrl, httpUtils: getIt<HttpUtils>()));
  getIt.registerLazySingleton<RoleNetworkService>(() => RoleNetworkServiceImpl(baseUrl: baseUrl, httpUtils: getIt<HttpUtils>()));
  getIt.registerLazySingleton<SkillNetworkService>(() => SkillNetworkServiceImpl(baseUrl: baseUrl, httpUtils: getIt<HttpUtils>()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  configureImplementations();

  runApp(
    const ProviderScope(
      child: MonApplication(),
    ),
  );
}