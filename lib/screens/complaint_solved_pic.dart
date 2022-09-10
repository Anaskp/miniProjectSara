import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_project/screens/admin_main.dart';
import 'package:mini_project/widgets/snackbar.dart';

class ComplaintSolvedPic extends StatefulWidget {
  const ComplaintSolvedPic({
    Key? key,
    required this.docUID,
  }) : super(key: key);
  final String docUID;

  @override
  State<ComplaintSolvedPic> createState() => _ComplaintSolvedPicState();
}

class _ComplaintSolvedPicState extends State<ComplaintSolvedPic> {
  File? image;
  bool _errorMessage = false;

  @override
  void initState() {
    pickImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add solved photo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image != null
                ? SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: InkWell(
                      onTap: () {
                        pickImage();
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[200],
                    ),
                    child: InkWell(
                      onTap: () {
                        pickImage();
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Take photo'),
                          ],
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            image == null && _errorMessage == true
                ? Column(
                    children: const [
                      Text(
                        'Please take complaint photo',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
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
                  submitComplaint();
                },
                child: const Text('Submit'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (image == null) return null;

      final imageTemporary = File(image.path);
      setState(
        () {
          this.image = imageTemporary;
        },
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message!),
        ),
      );
    }
  }

  void submitComplaint() async {
    setState(() {
      _errorMessage = true;
    });

    if (image != null) {
      var postValid = false;

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      try {
        final user = FirebaseAuth.instance.currentUser;
        var id = DateTime.now().toString() + user!.uid;

        final storageRef = FirebaseStorage.instance.ref();
        final profileRef = storageRef.child("complaintsSolved/$id");
        UploadTask uploadTask = profileRef.putFile(image!);
        String url = await (await uploadTask).ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('complaints')
            .doc(widget.docUID)
            .update({
          'imgSolvedUID': id,
          'imgSolved': url,
          'status': 'Work Completed',
          'track': 'solved',
          'homeFilter': 'Solved',
        });
        postValid = true;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AdminMain()),
            (route) => false);
      } catch (e) {
        GlobalSnackBar(text: e.toString());
      }

      if (postValid == false) Navigator.of(context).pop();
    }
  }
}
