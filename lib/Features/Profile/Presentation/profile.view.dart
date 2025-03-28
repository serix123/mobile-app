// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Profile/Data/Model/profile.model.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:online_reservation/Utils/utils.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  static const String screenId = "/Profile";
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ProfileProvider>().getProfile();
    return ResponsiveLayout(mobileBody: body(), desktopBody: body(), title: 'My Profile');
  }

  Consumer<ProfileProvider> body() {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50),
                const SizedBox(height: 16),
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: provider.getProfile,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final user = provider.user;
        if (user == null) {
          return const Center(child: Text('No profile data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              if (user.residence != null) _buildResidenceCard(user.residence!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.fullName),
              subtitle: Text(user.email),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Account Type'),
              subtitle: Text(user.isSuperuser
                  ? 'Administrator'
                  : user.isStaff
                      ? 'Security'
                      : 'Regular User'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidenceCard(Residence residence) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Residence Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow('Role', residence.role),
            _buildInfoRow('Contact', residence.formattedContact),
            _buildInfoRow('Address', residence.fullAddress),
            _buildInfoRow('Registered', Utils.formatDate(residence.registrationDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
