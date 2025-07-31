// lib/presentation/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/user.dart';
import 'package:odc_mobile_template/pages/profil/profil_ctrl.dart';
import 'package:odc_mobile_template/pages/profil/profil_state.dart';
import 'package:url_launcher/url_launcher.dart'; // Pour ouvrir les liens


class ProfilePage extends ConsumerStatefulWidget {
  final String userToken; // Le token de l'utilisateur connecté

  const ProfilePage({super.key, required this.userToken, required User user});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref.read pour accéder au contrôleur et appeler une méthode
      ref.read(profileControllerProvider.notifier).loadProfile(widget.userToken);
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le lien: $urlString')),
        );
      }
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch pour écouter les changements d'état du contrôleur
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil Utilisateur'),
      ),
      body: _buildBody(profileState),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Erreur: ${state.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(profileControllerProvider.notifier).loadProfile(widget.userToken),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    } else if (state.userProfile == null) {
      return const Center(child: Text('Aucune donnée de profil à afficher.'));
    } else {
      final userProfile = state.userProfile!; // Non-null car nous avons vérifié
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: userProfile.fullProfilePhotoUrl != null
                  ? NetworkImage(userProfile.fullProfilePhotoUrl!)
                  : null,
              child: userProfile.fullProfilePhotoUrl == null
                  ? const Icon(Icons.person, size: 70)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              userProfile.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              userProfile.jobTitle ?? 'Titre de poste non spécifié',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            if (userProfile.about != null && userProfile.about!.isNotEmpty)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'À propos de moi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(userProfile.about!),
                    ],
                  ),
                ),
              ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileDetail(Icons.email, 'Email', userProfile.email),
                    if (userProfile.emailVerifiedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text(
                          '(Vérifié)',
                          style: TextStyle(
                              color: Colors.green[700], fontStyle: FontStyle.italic),
                        ),
                      ),
                    _buildProfileDetail(
                        Icons.phone,
                        'Téléphone',
                        userProfile.phone ?? 'Non renseigné',
                        isNull: userProfile.phone == null),
                    _buildProfileDetail(
                        Icons.location_on,
                        'Localisation',
                        userProfile.location ?? 'Non renseignée',
                        isNull: userProfile.location == null),
                    _buildProfileDetail(
                        Icons.work,
                        'Disponibilité',
                        userProfile.availability ?? 'Non spécifiée',
                        isNull: userProfile.availability == null),
                    if (userProfile.portfolioUrl != null && userProfile.portfolioUrl!.isNotEmpty)
                      _buildProfileDetail(
                          Icons.link,
                          'Portfolio',
                          userProfile.portfolioUrl!,
                          isLink: true,
                          launchUrl: _launchUrl,
                      ),
                    _buildProfileDetail(
                        Icons.access_time,
                        'Membre depuis',
                        userProfile.formattedCreatedAt),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // --- Correction de la signature de la fonction _buildProfileDetail ---
  Widget _buildProfileDetail(
      IconData icon,
      String label,
      String value, { // <-- Début des paramètres nommés
        bool isNull = false,
        bool isLink = false,
        Future<void> Function(String)? launchUrl,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                if (isLink && launchUrl != null)
                  InkWell(
                    onTap: () => launchUrl(value),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: isNull ? Colors.grey[500] : Colors.black87,
                      fontStyle: isNull ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}