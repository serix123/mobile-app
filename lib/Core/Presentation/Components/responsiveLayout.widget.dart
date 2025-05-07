import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';

import '../../../Core/Presentation/Components/navigationDrawer.widget.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;
  final String currentRoute;
  final Widget title;
  final List<Widget>? actions;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
    this.currentRoute = "",
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return SafeArea(
            child: Scaffold(
              drawer: CustomNavigationDrawer(
                currentRoute: currentRoute,
              ),
              body: mobileBody,
              appBar: AppBar(
                title: title,
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  },
                ),
                actions: [
                  ...?actions,
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.profileScreen),
            
                    // isSelected: currentRoute == RouteGenerator.profileScreen,
                  ),
                  //  Add AppBar Items here
                ],
              ),
            ),
          );
        } else {
          return Row(
            children: <Widget>[
              CustomNavigationDrawer(
                currentRoute: currentRoute,
              ), // Permanent navigation drawer
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: title,
                    actions: [
                      ...?actions,
                      // IconButton(
                      //   icon: const Icon(Icons.person),
                      //   onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.profileScreen),
                      //   isSelected: true,
                      // ),
                    ],
                  ),
                  body: desktopBody,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
