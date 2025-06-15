import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
import 'package:online_reservation/Features/Resident/Domain/resident.repository.dart';
import 'package:online_reservation/Features/Users/Data/Model/user.model.dart';
import 'package:online_reservation/Features/Users/Domain/user.repository.dart';
import 'package:online_reservation/Utils/utils.dart';
import 'package:provider/provider.dart';

class UserScreenConfig {
  final User? user;
  final Resident? resident;
  UserScreenConfig({this.user, this.resident,});
}


class UserScreen extends StatefulWidget {
  static const String screenId = "/User";
  final User? user;
  const UserScreen({super.key, this.user});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {


  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    // WidgetsBinding.instance.addPostFrameCallback((_)  {
    //   if (mounted) context.read<ResidentProvider>().getResident(residentId: widget.user!.id);
    // });
  }

  @override  Widget build(BuildContext context) {
    return ResponsiveLayout(mobileBody: body(), desktopBody: body(), title: const Text('My Profile'));
  }

  Widget body() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        String? error = userProvider.error;
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50),
                const SizedBox(height: 16),
                Text(error),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: ()=> Navigator.pop(context),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (widget.user == null) {
          return const Center(child: Text('No profile data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(widget.user!),
              const SizedBox(height: 24),
              _buildResidenceCard(widget.user!),
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
              subtitle: Text(user.group ?? ""),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidenceCard(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow('Full Name', user.fullName),
            _buildInfoRow('Role', user.group ?? ""),
            _buildInfoRow('Email', user.email),
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
