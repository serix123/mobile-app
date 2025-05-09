import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
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
    // Provider.of<ProfileProvider>(context, listen: false).getProfile();
    // Provider.of<EmployeeViewModel>(context,listen: false).fetchProfile();
    return Drawer(
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child:
                Consumer<UserInfoProvider>(builder: (context, provider, child) {
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
                    // child: Text(
                    //   'Navigation',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 24,
                    //   ),
                    // ),
                  ),

                  _createDrawerItem(
                    context: context,
                    icon: Icons.book_online,
                    text: 'Home',
                    onTap: () => Navigator.of(context)
                        .pushNamed(RouteGenerator.homeScreen),
                    selected: currentRoute == RouteGenerator.homeScreen,
                  ),
                if(provider.user!.isStaff)
                 ...[ _createDrawerItem(
                    context: context,
                    icon: Icons.menu_book,
                    text: 'Medical Records',
                    onTap: () => Navigator.of(context)
                        .pushNamed(RouteGenerator.medicalRecordsList),
                    selected: currentRoute == RouteGenerator.medicalRecordsList,
                  ),
                  _createDrawerItem(
                    context: context,
                    icon: Icons.screen_search_desktop,
                    text: 'Inventory',
                    onTap: () {},
                    // onTap: () => Navigator.of(context)
                    //     .pushNamed(RouteGenerator.issuesListScreen),
                    selected: currentRoute == RouteGenerator.issuesListScreen,
                  ),]
                  // if(provider.user!.isSuperuser)
                  // _createDrawerItem(
                  //   context: context,
                  //   icon: Icons.people,
                  //   text: 'Users',
                  //   onTap: () => Navigator.of(context)
                  //       .pushNamed(RouteGenerator.userListScreen),
                  //   selected:
                  //   currentRoute == RouteGenerator.userListScreen,
                  // ),
                  // if (provider.user!.isSuperuser)
                  //   _createDrawerItem(
                  //     context: context,
                  //     icon: Icons.people,
                  //     text: 'Residents',
                  //     onTap: () => Navigator.of(context)
                  //         .pushNamed(RouteGenerator.residentListScreen),
                  //     selected:
                  //         currentRoute == RouteGenerator.residentListScreen,
                  //   ),
                  // _createDrawerItem(
                  //   context: context,
                  //   icon: Icons.schedule,
                  //   text: "Scheduled Reservations",
                  //   onTap: () {},
                  //   selected: true,
                  // ),
                  // _createDrawerItem(
                  //   context: context,
                  //   icon: Icons.list,
                  //   text: "My Reservations",
                  //   onTap: () {},
                  //   selected: true,
                  // ),
                  // if (hasPICApproval)
                  //   _createDrawerItem(
                  //     context: context,
                  //     icon: Icons.list,
                  //     text: "For Person-in-Charge",
                  //     onTap: () => Navigator.of(context)
                  //         .pushNamed(RouteGenerator.approvalListScreen),
                  //     selected:
                  //         currentRoute == RouteGenerator.approvalListScreen,
                  //   ),
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
