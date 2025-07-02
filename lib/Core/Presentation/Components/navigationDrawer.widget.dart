import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';

import 'package:online_reservation/config/app.color.dart';
import 'package:online_reservation/config/config.dart';
import 'package:provider/provider.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final String currentRoute;
  const CustomNavigationDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      if (profileProvider.user == null && !profileProvider.isLoading) {
        profileProvider.getProfile();
      }
    });

    return Drawer(
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child:
                Consumer<ProfileProvider>(builder: (context, provider, child) {
                  if(provider.isLoading || provider.user == null) return const Center(child: CircularProgressIndicator(),);
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: kBackgroundGrey,
                    ),
                    child: Image.asset(
                      logoPath,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  _createDrawerItem(
                    context: context,
                    icon: Icons.space_dashboard_outlined,
                    text: 'Dashboard',
                    onTap: () => Navigator.of(context)
                        .pushNamed(RouteGenerator.dashboardScreen),
                    selected: currentRoute == RouteGenerator.dashboardScreen,
                  ),
                  _createDrawerItem(
                    context: context,
                    icon: Icons.campaign_outlined,
                    text: 'Community Notice',
                    onTap: () => Navigator.of(context)
                        .pushNamed(RouteGenerator.noticeListScreen),
                    selected: currentRoute == RouteGenerator.noticeListScreen,
                  ),
                  _createDrawerItem(
                    context: context,
                    icon: Icons.event_note_outlined,
                    text: 'Events   ',
                    onTap: () => Navigator.of(context)
                        .pushNamed(RouteGenerator.eventListScreen),
                    selected: currentRoute == RouteGenerator.eventListScreen,
                  ),
                  _createDrawerItem(
                    context: context,
                    icon: Icons.approval,
                    text: 'Issues',
                    onTap: () => Navigator.of(context)
                        .pushNamed(RouteGenerator.issuesListScreen),
                    selected: currentRoute == RouteGenerator.issuesListScreen,
                  ),
                  _createDrawerItem(
                    context: context,
                    icon: Icons.file_copy_outlined,
                    text: 'Community Documents',
                    onTap: () => Navigator.of(context)
                        .pushNamed(RouteGenerator.documentListScreen),
                    selected: currentRoute == RouteGenerator.documentListScreen,
                  ),
                  if (!provider.user!.isResident)
                    _createDrawerItem(
                      context: context,
                      icon: Icons.people,
                      text: 'GL1 Community',
                      onTap: () => Navigator.of(context)
                          .pushNamed(RouteGenerator.residentListScreen),
                      selected:
                          currentRoute == RouteGenerator.residentListScreen,
                    ),
                ],
              );
            }),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Divider(
              height: 2,
            ),
          ),
          Expanded(
            flex: 1,
            child: ListTile(
              leading: const Icon(
                Icons.exit_to_app,
                color: kGreenNormal,
              ),
              title: const Text('Logout'),
              onTap: () {
                authProvider.logout();
                {
                  const snackBar =
                      SnackBar(content: Text('User will be logged out'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteGenerator.loginScreen,
                  (Route<dynamic> route) =>
                      false, // This condition ensures all other screens are removed
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required bool selected,
  }) {
    return ListTile(
      leading: Icon(icon, color: kGreenNormal),
      title: Text(text),
      onTap: onTap,
      selected: selected,
      selectedTileColor: Colors.blue[100],
    );
  }
}
