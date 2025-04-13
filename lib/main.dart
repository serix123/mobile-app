import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:online_reservation/Core/Data/API_Services/user.info.service.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Features/Authentication/Presentation/login.view.dart';
import 'package:online_reservation/Features/CommunityResources/Data/Service/community_resource.service.dart';
import 'package:online_reservation/Features/CommunityResources/Domain/community_resource.repository.dart';
import 'package:online_reservation/Features/Issue/Data/Service/issue.service.dart';
import 'package:online_reservation/Features/Issue/Domain/issue.repository.dart';
import 'package:online_reservation/Features/MedApplication/Data/Service/application.service.dart';
import 'package:online_reservation/Features/MedApplication/Domain/application.repository.dart';
import 'package:online_reservation/Features/Profile/Data/Service/profile.service.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:online_reservation/Features/Resident/Data/Service/resident.service.dart';
import 'package:online_reservation/Features/Resident/Domain/resident.repository.dart';
import 'package:online_reservation/Features/Users/Data/Service/user.service.dart';
import 'package:online_reservation/Features/Users/Domain/user.repository.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Authentication/Data/Service/auth.service.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:online_reservation/Features/Visitor/Data/Service/visitor.service.dart';
import 'package:online_reservation/Features/Visitor/Domain/visitor.repository.dart';

void main() async {
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await initPathProvider();
  }
  runApp(const MyApp());
}

Future<void> initPathProvider() async {
  // Get the application documents directory
  await getApplicationDocumentsDirectory();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => const FlutterSecureStorage()),
        Provider(create: (_) => http.Client()),
        Provider(
            create: (context) =>
                AuthService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        Provider(
            create: (context) =>
                VisitApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        Provider(
            create: (context) =>
                IssueApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        Provider(
            create: (context) =>
                ProfileApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        Provider(
            create: (context) =>
                UserApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        Provider(
            create: (context) =>
                ResidentApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        Provider(
            create: (context) =>
                ResourceApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        Provider(
            create: (context) =>
                ApplicationApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        Provider(
            create: (context) =>
                UserInfoApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        ChangeNotifierProvider(create: (context) => AuthProvider(context.read<AuthService>())),
        ChangeNotifierProvider(create: (context) => VisitProvider(context.read<VisitApiService>())),
        ChangeNotifierProvider(create: (context) => IssueProvider(context.read<IssueApiService>())),
        ChangeNotifierProvider(create: (context) => ProfileProvider(context.read<ProfileApiService>()..getProfile())),
        ChangeNotifierProvider(create: (context) => UserProvider(context.read<UserApiService>()..getUsers())),
        ChangeNotifierProvider(create: (context) => ResidentProvider(context.read<ResidentApiService>())),
        ChangeNotifierProvider(create: (context) => ResourceProvider(context.read<ResourceApiService>())),
        ChangeNotifierProvider(create: (context) => ApplicationProvider(context.read<ApplicationApiService>())),
        ChangeNotifierProvider(create: (context) => UserInfoProvider(context.read<UserInfoApiService>())),
      ],
      child: Consumer<AuthProvider>(builder: (context, authProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Online Residence App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
            useMaterial3: true,
          ),
          // home: const LoginScreen(),
          initialRoute: authProvider.isLoggedIn ? RouteGenerator.visitorListScreen : RouteGenerator.loginScreen,
          // initialRoute: RouteGenerator.approvalListScreen,
          onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings, authProvider.isLoggedIn, context),
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const String screenId = "/";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void stateHandler() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentRoute: MyHomePage.screenId,
      title: const Text("Home Page"),
      desktopBody: ListView(
        children: <Widget>[
          cardTile(
            context,
            title: "GL1 Hub",
            icon: Icons.book_online,
            routeName: RouteGenerator.visitorFormScreen,
          ),
        ],
      ),
      mobileBody: const Center(child: Text("data")),
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
