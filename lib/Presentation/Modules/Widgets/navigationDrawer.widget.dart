import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:online_reservation/Presentation/route/route.generator.dart';

import 'package:online_reservation/config/app.color.dart';
import 'package:provider/provider.dart';

class CustomNavigationDrawer extends StatelessWidget {
  // final String currentRoute;

  const CustomNavigationDrawer({super.key
    // ,    required this.currentRoute
  });

  @override
  Widget build(BuildContext context) {
    // Provider.of<EmployeeViewModel>(context,listen: false).fetchProfile();
    return Drawer(
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: kPurpleLight,
                  ),
                  child: Image.asset('assets/images/SISC_BANNER.png'),
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
                  text: 'Online Reservation',
                  onTap: () {},
                  selected: true
                  // currentRoute == RouteGenerator.reservationScreen,
                ),
                _createDrawerItem(
                  context: context,
                  icon: Icons.approval,
                  text: 'Request Approval',
                  onTap: () {},
                  selected:true
                  // currentRoute == RouteGenerator.approvalListScreen,
                ),
                _createDrawerItem(
                  context: context,
                  icon: Icons.schedule,
                  text: "Scheduled Reservations",
                  onTap: () {},
                  selected: true,
                ),
                _createDrawerItem(
                  context: context,
                  icon: Icons.list,
                  text: "My Reservations",
                  onTap: () {},
                  selected: true,
                ),
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
            ),
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
                color: kPurpleDark,
              ),
              title: const Text('Logout'),
              onTap: () {
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
      leading: Icon(icon, color: kPurpleDark),
      title: Text(text),
      onTap: onTap,
      selected: selected,
      selectedTileColor: Colors.blue[100],
    );
  }
}
