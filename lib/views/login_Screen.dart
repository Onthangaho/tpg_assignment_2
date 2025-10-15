/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */

import 'package:flutter/material.dart';
import 'package:login_form/auth/auth.dart';
import 'package:login_form/reg.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  void login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = Provider.of<Auth>(context, listen: false);

        await authService.login(context, emailController.text.trim(),
            passwordController.text.trim(), rememberMe);
      } catch (error) {
        if (!mounted) return;

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                     const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Enter your email"
                          : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Enter your password"
                          : null,
                    ),
                    CheckboxListTile(
                      title: const Text(
                          'Remember Me'), // 🔹 Show "Remember Me" toggle
                      value: rememberMe,
                      onChanged: (value) => setState(() {
                        rememberMe = value!;
                      }),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => login(context),
                      child: const Text("Login"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegForm(),
                          )),
                      child: const Text("Don't have an account? Register",style: TextStyle(color: Colors.deepPurple)),
                    ),
                  ],
                  )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
