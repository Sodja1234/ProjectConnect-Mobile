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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mon Profil Utilisateur'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Erreur: ${state.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(profileControllerProvider.notifier).loadProfile(widget.userToken),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    } else if (state.userProfile == null) {
      return const Center(
        child: Text(
          'Aucune donnée de profil à afficher.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      final userProfile = state.userProfile!; // Non-null car nous avons vérifié
      return SingleChildScrollView(
        child: Column(
          children: [
            // Header avec gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Photo de profil avec bordure
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: userProfile.fullProfilePhotoUrl != null
                          ? NetworkImage(userProfile.fullProfilePhotoUrl!)
                          : null,
                      child: userProfile.fullProfilePhotoUrl == null
                          ? const Icon(Icons.person, size: 70, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Nom et titre
                  Text(
                    userProfile.name ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProfile.jobTitle ?? 'Titre de poste non spécifié',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Section À propos
                  if (userProfile.about != null && userProfile.about!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Theme.of(context).primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'À propos de moi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userProfile.about!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Section Informations de contact
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.contact_mail,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Informations de contact',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildProfileDetail(Icons.email, 'Email', userProfile.email ?? ''),
                          if (userProfile.emailVerifiedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 56, top: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 14, color: Colors.green[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Vérifié',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
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
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProfileDetail(
      IconData icon,
      String label,
      String value, {
        bool isNull = false,
        bool isLink = false,
        Future<void> Function(String)? launchUrl,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                if (isLink && launchUrl != null)
                  InkWell(
                    onTap: () => launchUrl(value),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: isNull ? Colors.grey[500] : Colors.grey[800],
                      fontStyle: isNull ? FontStyle.italic : FontStyle.normal,
                      fontWeight: FontWeight.w500,
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
