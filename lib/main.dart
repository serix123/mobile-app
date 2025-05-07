import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:online_reservation/Features/MedicalInventory/Data/Service/inventory.service.dart';
import 'package:online_reservation/Features/MedicalInventory/Domain/inventory.repository.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Service/medicalRecord.service.dart';
import 'package:online_reservation/Features/MedicalRecords/Domain/MedicalRecord.repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:online_reservation/Core/Data/API_Services/user.info.service.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Features/Authentication/Data/Service/auth.service.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
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
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
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
                UserInfoApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
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
                MedicalRecordApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        Provider(
            create: (context) =>
                InventoryApiService(storage: context.read<FlutterSecureStorage>(), client: context.read<http.Client>())),
        ChangeNotifierProvider(create: (context) => UserInfoProvider(context.read<UserInfoApiService>())),
        ChangeNotifierProvider(create: (context) => AuthProvider(context.read<AuthService>())),
        ChangeNotifierProvider(create: (context) => VisitProvider(context.read<VisitApiService>())),
        ChangeNotifierProvider(create: (context) => IssueProvider(context.read<IssueApiService>())),
        ChangeNotifierProvider(create: (context) => ProfileProvider(context.read<ProfileApiService>())),
        ChangeNotifierProvider(create: (context) => UserProvider(context.read<UserApiService>()..getUsers())),
        ChangeNotifierProvider(create: (context) => ResidentProvider(context.read<ResidentApiService>())),
        ChangeNotifierProvider(create: (context) => ResourceProvider(context.read<ResourceApiService>())),
        ChangeNotifierProvider(create: (context) => ApplicationProvider(context.read<ApplicationApiService>())),
        ChangeNotifierProvider(create: (context) => MedicalRecordProvider(context.read<MedicalRecordApiService>())),
        ChangeNotifierProvider(create: (context) => InventoryProvider(context.read<InventoryApiService>())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Online Residence App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
          useMaterial3: true,
        ),
        initialRoute: RouteGenerator.loginScreen,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
