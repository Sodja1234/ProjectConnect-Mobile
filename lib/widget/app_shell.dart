// lib/widgets/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importez VOS écrans existants qui seront les onglets
// Ces imports ne sont pas directement utilisés dans ce fichier mais sont conservés pour référence.
// Ils peuvent apparaître en gris, ce qui est normal pour cette architecture.
import 'package:odc_mobile_template/pages/home/homePage.dart';
import 'package:odc_mobile_template/pages/listProject/listProjectPage.dart';
//import 'package:odc_mobile_template/pages/createProject/createProjectPage.dart';

// --- Définition des couleurs directement ici ---
const Color primaryColor = Color(0xFF1A1A1A);
const Color accentColor = Color(0xFFFF6B35);
const Color lightGray = Color(0xFFF8F9FA);
const Color mediumGray = Color(0xFFE9ECEF);
const Color darkGray = Color(0xFF6C757D);
const Color cardBackground = Colors.white;

class AppShell extends StatefulWidget {
  final Widget child; // Le contenu de la route actuelle
  final String currentLocation; // L'emplacement actuel de la route

  const AppShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Ces routes doivent correspondre EXACTEMENT aux chemins de vos GoRoute enfants dans ShellRoute.
  // L'ordre est important car il correspond à l'ordre des BottomNavigationBarItem.
  // J'ai ajusté l'ordre ici pour correspondre aux labels de la BottomNavigationBar
  // et aux routes les plus logiques (Accueil -> /app/home, Projets -> /app/projects).
  final List<String> _routes = [
    '/app/home',              // 0: Accueil
    '/app/projects',          // 1: Projets
    '/app/create/project',    // 2: Créer
    '/app/notifications',     // 3: Notifications
    '/app/jobs',              // 4: Emplois (ou "Mes Projets" si c'est ce que vous voulez)
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex(widget.currentLocation);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocation != oldWidget.currentLocation) {
      _updateCurrentIndex(widget.currentLocation);
    }
  }

  void _updateCurrentIndex(String location) {
    // Utiliser `startsWith` permet de matcher les sous-routes (ex: /app/projects/detail)
    final index = _routes.indexWhere((route) => location.startsWith(route));
    if (index != -1 && _currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onItemTapped(int index) {
    // Ne rien faire si l'onglet est déjà sélectionné (sauf pour le bouton "Créer")
    if (index == _currentIndex && index != 2) return;

    if (index == 2) { // Cas spécial pour le bouton "Créer" (index 2)
      debugPrint('Bouton Créer tapé !');
      GoRouter.of(context).push(_routes[index]);
    } else {
      GoRouter.of(context).go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR STYLE LINKEDIN ---
      appBar: AppBar(
        backgroundColor: cardBackground, // Utilise votre couleur primaire pour le fond de l'AppBar
        elevation: 1, // Une légère ombre sous l'AppBar
        toolbarHeight: 60, // Hauteur de la barre
        titleSpacing: 0, // Supprime l'espace par défaut à gauche du titre

        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              // --- REDIRECTION VERS LA PAGE DE PROFIL ICI ---
              debugPrint('Icône Profil/Menu tapée ! Redirection vers /app/profile');
              GoRouter.of(context).go('/app/profil'); // Navigue vers la page de profil
            },
            child: CircleAvatar(
              backgroundColor: accentColor, // Exemple de couleur pour l'avatar
              // Vous pouvez remplacer le Text par un Image.network ou Image.asset
              child: const Text( // Utiliser const si le contenu est statique
                'M', // Initiale de l'utilisateur ou icône
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        title: Container(
          height: 40, // Hauteur de la barre de recherche
          margin: const EdgeInsets.symmetric(horizontal: 10.0), // Marge horizontale
          decoration: BoxDecoration(
            color: darkGray, // Couleur de fond du champ de recherche
            borderRadius: BorderRadius.circular(8.0), // Bords arrondis
          ),
          child: TextField(
            readOnly: true, // Empêche l'édition directe, le tap ouvre une autre page
            onTap: () {
              // Action pour ouvrir la page de recherche (GoRouter push pour une nouvelle page)
              debugPrint('Champ de recherche tapé !');
              // Exemple: GoRouter.of(context).push('/app/search');
            },
            decoration: const InputDecoration( // Utiliser const si le contenu est statique
              hintText: 'Rechercher',
              hintStyle: TextStyle(color: lightGray), // Couleur du texte d'aide
              prefixIcon: Icon(Icons.search, color: lightGray), // Icône de recherche
              contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Ajuste le padding interne
              border: InputBorder.none, // Supprime la bordure par défaut
              isDense: true, // Rend le champ plus compact
            ),
            style: const TextStyle(color: Colors.white), // Couleur du texte tapé dans le champ
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_rounded, color: accentColor), // Icône de messages
            onPressed: () {
              // Action pour les messages
              debugPrint('Icône Messages tapée !');
              // Exemple: GoRouter.of(context).push('/app/messages');
            },
          ),
          const SizedBox(width: 8.0), // Espacement à droite
        ],
      ),
      // --- FIN APP BAR ---

      body: widget.child, // Affiche le widget enfant (la page de la route GoRouter actuelle)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        // --- UTILISATION DES COULEURS POUR LA BOTTOM NAV BAR ---
        selectedItemColor: accentColor, // Votre couleur d'accent pour l'élément sélectionné
        unselectedItemColor: darkGray, // Votre gris foncé pour les éléments non sélectionnés
        backgroundColor: cardBackground, // <--- CORRECTION ICI : Utilisez cardBackground (blanc)
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed, // Nécessaire pour plus de 3 éléments
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Projets', // Correspond à /app/projects
          ),
          BottomNavigationBarItem(
            // C'est votre bouton central "Créer"
            icon: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: accentColor, // Utilisation de l'accentColor pour le bouton "Créer"
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(Icons.add, color: Colors.white), // Icône blanche pour un bon contraste
            ),
            label: 'Créer', // Texte pour le bouton central
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Mes Projets', // Correspond à /app/jobs si vous voulez, ou Emplois.
            // Assurez-vous que le nom de la route et le label correspondent à ce que vous voulez.
          ),
        ],
      ),
    );
  }
}