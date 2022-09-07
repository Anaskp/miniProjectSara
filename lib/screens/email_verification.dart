import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mini_project/screens/admin_main.dart';
import 'package:mini_project/screens/auth_screen.dart';
import 'package:mini_project/screens/main_screen.dart';
import 'package:mini_project/widgets/snackbar.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool canResend = false;
  bool isEmailVerified = false;
  bool isAdmin = false;
  Timer? timer;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    checkIsAdmin(user!.uid);

    isEmailVerified = user!.emailVerified;
    if (!isEmailVerified) {
      sendVerification(context);
      timer = Timer.periodic(const Duration(seconds: 5), (_) {
        checkEmailVerified();
      });
    }

    super.initState();
  }

  Future<bool> checkIsAdmin(String docID) async {
    try {
      await FirebaseFirestore.instance
          .doc("adminData/$docID")
          .get()
          .then((doc) {
        setState(() {
          isAdmin = doc.exists;
        });
      });

      return isAdmin;
    } catch (e) {
      return false;
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (isEmailVerified && isAdmin)
        ? AdminMain()
        : isEmailVerified
            ? MainScreen()
            : Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'A verification email has sent to your email address(Please check spam folder)',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: AbsorbPointer(
                            absorbing: canResend ? false : true,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {},
                              child: canResend
                                  ? const Text(
                                      'Send verification link',
                                    )
                                  : const CircularProgressIndicator(
                                      color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const AuthScreen()),
                                  (route) => false);
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
  }

  Future sendVerification(context) async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      setState(() {
        canResend = false;
      });

      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        canResend = true;
      });
    } on FirebaseAuthException catch (e) {
      GlobalSnackBar.show(context, e.message);
    }
  }
}

class RouteConfig extends StatefulWidget {
  bool isAdmin;
  RouteConfig({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<RouteConfig> createState() => _RouteConfigState();
}

class _RouteConfigState extends State<RouteConfig> {
  @override
  void initState() {
    print(widget.isAdmin);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isAdmin ? AdminMain() : const MainScreen();
  }
}
