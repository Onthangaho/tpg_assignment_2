// ignore_for_file: use_build_context_synchronously
/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_form/auth/auth.dart';

import 'package:provider/provider.dart';

class RegForm extends StatefulWidget {
  const RegForm({super.key});

  @override
  State<RegForm> createState() => _RegFormState();
}

class _RegFormState extends State<RegForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController studentNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController contactController = TextEditingController();
  bool isAdmin = false;
  bool isLogin = false;
  bool rememberMe = false;

  void submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String name = nameController.text.trim();
      String studentNumber = studentNumberController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String confirmPassword = confirmPasswordController.text.trim();
      String contactNumber = contactController.text.trim();

      final authService = Provider.of<Auth>(context, listen: false);

      try {
        if (isLogin) {
          await authService.login(context, email, password, rememberMe);
        } else if (password != confirmPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Passwords do not match!")),
          );
          return;
        }

        await authService.register(
            context,
            name,
            email,
            password,
            isAdmin ? null : studentNumber,
            isAdmin ? null : contactNumber,
            isAdmin);
      } catch (error) {
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
                end: Alignment.bottomCenter)),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLogin ? "Welcome Back!" : "Create Account",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 20),
                        if (!isLogin)
                          SwitchListTile(
                            title: const Text('Register as Admin'),
                            value: isAdmin,
                            onChanged: (value) => setState(() {
                              isAdmin = value;
                            }),
                          ),
                        if (!isLogin)
                          TextFormField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                          ),
                        if (!isLogin && !isAdmin)
                          TextFormField(
                            controller: studentNumberController,
                            decoration: const InputDecoration(
                                labelText: 'student number'),
                          ),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'email'),
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                        ),
                        if (!isLogin)
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true, // 🔹 Hide confirm password
                            decoration: const InputDecoration(
                                labelText: 'Confirm Password'),
                          ),
                        if (!isLogin)
                          TextFormField(
                            controller: contactController,
                            decoration: const InputDecoration(
                                labelText: 'Contact Number'),
                          ),
                        if (isLogin)
                          CheckboxListTile(
                            title: const Text(
                                'Remember Me'), // 🔹 Show "Remember Me" toggle only on login
                            value: rememberMe,
                            onChanged: (value) => setState(() {
                              rememberMe = value!;
                            }),
                          ),
                        ElevatedButton(
                          onPressed: () => submit(context),
                          child: Text(isLogin ? 'login' : 'Register'),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            isLogin = !isLogin;
                          }),
                          child: Text(isAdmin
                              ? "Don't have an account? Register"
                              : "Already registered?",
                              style: const TextStyle(color: Colors.deepPurple),
),
                        )
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
