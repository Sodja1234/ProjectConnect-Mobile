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
// Il est généralement recommandé de les mettre dans un fichier séparé pour la réutilisabilité,
// mais pour une intégration directe comme demandé, elles sont ici.
const Color primaryColor = Color(0xFF1A1A1A);
const Color accentColor = Color(0xFFFF6B35);
const Color lightGray = Color(0xFFF8F9FA);
const Color mediumGray = Color(0xFFE9ECEF);
const Color darkGray = Color(0xFF6C757D);
const Color cardBackground = Colors.white; // C'est déjà Color(0xFFFFFFFF)

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
  // Nous utilisons ici vos pages existantes pour les onglets.
  final List<String> _routes = [
    '/app/projects',              // 0: Accueil (HomePage pour vos articles)
    '/app/home',          // 1: Projets (ListProjectPage pour la liste des projets)
    '/app/create/project',    // 2: Créer (ProjectFormPage, accessible via push)
    '/app/notifications',     // 3: Notifications (page simple, à implémenter si ce n'est pas déjà fait)
    '/app/jobs',              // 4: Emplois (page simple, à implémenter si ce n'est pas déjà fait)
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
    // Si la route actuelle ne correspond pas à un onglet principal (ex: une page de détail profonde),
    // l'onglet précédent restera sélectionné, ce qui est souvent le comportement souhaité.
  }

  void _onItemTapped(int index) {
    // Ne rien faire si l'onglet est déjà sélectionné (sauf pour le bouton "Créer")
    if (index == _currentIndex && index != 2) return;

    if (index == 2) { // Cas spécial pour le bouton "Créer" (index 2)
      debugPrint('Bouton Créer tapé !');
      // Pour une action comme "Publier" ou "Créer", on utilise souvent un `push`
      // pour ajouter la page par-dessus la pile de navigation.
      GoRouter.of(context).push(_routes[index]); // Navigue vers '/app/create/project'
    } else {
      // Pour les autres onglets, utilisez `.go()` pour naviguer et réinitialiser
      // potentiellement la pile de navigation de cet onglet.
      GoRouter.of(context).go(_routes[index]);
    }
    // L'index sera mis à jour automatiquement par `didUpdateWidget` lorsque GoRouter change la route.
    // Pas besoin d'un `setState()` direct ici pour `_currentIndex` après un `go()`.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child, // Affiche le widget enfant (la page de la route GoRouter actuelle)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        // --- UTILISATION DIRECTE DES COULEURS ICI ---
        selectedItemColor: accentColor, // Votre couleur d'accent pour l'élément sélectionné
        unselectedItemColor: darkGray, // Votre gris foncé pour les éléments non sélectionnés
        backgroundColor: cardBackground, // Votre couleur primaire pour le fond de la barre
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
            label: 'Projets', // Renommé pour correspondre à ListProjectPage
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
          // Pour ces onglets, si vous n'avez pas de pages spécifiques existantes,
          // vous devrez créer de simples placeholders ou de vraies pages.
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Mes Projets',
          ),
        ],
      ),
    );
  }
}