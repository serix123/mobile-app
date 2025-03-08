import 'package:flutter/material.dart';

import 'navigationDrawer.widget.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;
  final String currentRoute;
  final String title;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
    required this.currentRoute,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if(constraints.maxWidth < 600){
        return Scaffold(
          drawer: const CustomNavigationDrawer(
            // currentRoute: currentRoute,
          ),
          body: mobileBody,
          appBar: AppBar(
            title: Text(title),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {},
                    // Navigator.of(context)
                    // .pushNamed(RouteGenerator.profileScreen),
                // isSelected: currentRoute == RouteGenerator.profileScreen,
              ),
            //  Add AppBar Items here
            ],
          ),
        );
      }else{
        return Row(
          children: <Widget>[
            const CustomNavigationDrawer(
              // currentRoute: currentRoute,
            ), // Permanent navigation drawer
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {},
                      isSelected:true,
                    ),
                  ],
                ),
                body: desktopBody,
              ),
            ),
          ],
        );
      }
    },);
  }
}
