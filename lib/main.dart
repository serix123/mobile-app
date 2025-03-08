import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:online_reservation/Presentation/Modules/Widgets/responsiveLayout.widget.dart';
import 'package:online_reservation/Presentation/route/route.generator.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Residence App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      initialRoute: RouteGenerator.homeScreen,
      // initialRoute: RouteGenerator.approvalListScreen,
      onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings, context),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const String screenId = "/home";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void stateHandler() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      currentRoute: MyHomePage.screenId,
      title: "Home Page",
      desktopBody: Center(child: Text("data")),
      mobileBody: Center(child: Text("data")),
    );
  }

  Widget cardTile(BuildContext context, {required String title, required IconData icon, required String routeName}) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2, // Adjust shadow elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        onTap: () => Navigator.of(context).pushNamed(routeName),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
