import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:online_reservation/config/config.dart';
import 'package:provider/provider.dart';

import 'package:online_reservation/Core/Presentation/Components/customCard.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/config/app.color.dart';

class LoginScreen extends StatefulWidget {
  static const String screenId = "/login";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  void _login() async {
    final authProvider = context.read<AuthProvider>();
    final userInfoProvider = context.read<UserInfoProvider>();
    await authProvider
        .login(emailController.text, passwordController.text)
        .then((_) async {
      if (authProvider.isLoggedIn) {
        setState(() {
          emailController.clear();
          passwordController.clear();
        });
        await userInfoProvider.getUserInfo();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            RouteGenerator.homeScreen,
          );
        }
      }
    });
  }



  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Login"),
        ),
        body: body(),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 30),
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer2<AuthProvider, UserInfoProvider>(
              builder: (context, authProvider, userInfoProvider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 180,
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        logoPath,
                        fit: BoxFit.cover,
                      )),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.green.shade50,
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green.shade50,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green.shade50,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kGreenDark, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.green.shade50,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green.shade50,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green.shade50,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kGreenDark, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 40),
                if (authProvider.isLoading || userInfoProvider.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      _login();
                      if (authProvider.isLoggedIn) {
                        // if (mounted) {
                        //   Navigator.of(context).pushReplacementNamed(
                        //     RouteGenerator.homeScreen,
                        //   );
                        // }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Login'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(RouteGenerator.registerScreen);
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
