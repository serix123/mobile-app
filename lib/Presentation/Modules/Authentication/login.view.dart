import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:online_reservation/Presentation/Modules/Widgets/customCard.widget.dart';
import 'package:online_reservation/Presentation/route/route.generator.dart';
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
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 30),
        child: CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.deepPurple.shade50,
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurple.shade50,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurple.shade50,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kPurpleDark, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.deepPurple.shade50,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurple.shade50,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurple.shade50,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kPurpleDark, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    // Navigator.of(context)
                    //     .pushReplacementNamed(RouteGenerator.registerScreen);
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
