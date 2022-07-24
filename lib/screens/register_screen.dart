import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_project/screens/screens.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:mini_project/widgets/snackbar.dart';

class RegisterScreen extends StatefulWidget {
  final Function onClickLogin;

  const RegisterScreen({super.key, required this.onClickLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  File? image;

  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SpinWidget()
        : Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Register',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            'Please enter the details below to continue',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.grey,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              pickImage(ImageSource.camera);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Camera',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              pickImage(ImageSource.gallery);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Gallery',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  radius: 60,
                                  backgroundImage: image != null
                                      ? FileImage(image!)
                                      : AssetImage('assets/avatar.png')
                                          as ImageProvider,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(Icons.edit)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[200],
                            ),
                            child: TextFormField(
                              validator: (name) =>
                                  name == null ? 'Enter valid name' : null,
                              controller: _nameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Name',
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[200],
                            ),
                            child: TextFormField(
                              validator: (email) => email != null &&
                                      !EmailValidator.validate(email)
                                  ? 'Enter valid email'
                                  : null,
                              controller: _emailController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email',
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[200],
                            ),
                            child: TextFormField(
                              validator: (pass) =>
                                  pass != null && pass.length < 6
                                      ? 'Enter minimum 6 character'
                                      : null,
                              controller: _passController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[200],
                            ),
                            child: TextFormField(
                              validator: (conPass) => conPass != null &&
                                      conPass != _passController.text
                                  ? 'Password doesn\'t match'
                                  : null,
                              controller: _confirmPassController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Confirm Password',
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                signUp();
                              },
                              child: const Text('Sign Up'),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              text: 'Have an acccount! ',
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      widget.onClickLogin();
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> signUp() async {
    final isValid = _formKey.currentState!.validate();

    if (image == null) {
      GlobalSnackBar.show(context, 'Please add a profile picture');
    }

    if (isValid && image != null) {
      //spin();

      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );

        final storageRef = FirebaseStorage.instance.ref();
        final profileRef = storageRef
            .child("profile/${FirebaseAuth.instance.currentUser!.uid}");
        UploadTask uploadTask = profileRef.putFile(image!);
        String url = await (await uploadTask).ref.getDownloadURL();

        FirebaseFirestore.instance
            .collection('usersData')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set(
          {
            'name': _nameController.text,
            'email': _emailController.text,
            'profileUrl': url,
          },
        );

        setState(() {
          isLoading = false;
        });

        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => EmailVerificationScreen()));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const EmailVerificationScreen()),
            (route) => false);
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });

        GlobalSnackBar.show(context, e.message);
        //Navigator.of(context).pop();
      }
    }
  }

  Future<dynamic> spin() {
    return showDialog(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Future pickImage(source) async {
    try {
      final image =
          await ImagePicker().pickImage(source: source, imageQuality: 50);
      if (image == null) return null;

      final imageTemporary = File(image.path);
      setState(
        () {
          this.image = imageTemporary;
        },
      );
    } on PlatformException catch (e) {
      GlobalSnackBar.show(context, e.message);
    }
  }
}

class SpinWidget extends StatelessWidget {
  const SpinWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text(
              'Registering User',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
