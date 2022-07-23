import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mini_project/screens/auth_screen.dart';
import 'package:mini_project/widgets/snackbar.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);
  String? userName;
  String? profileUrl;

  final _myComplaints = FirebaseFirestore.instance
      .collection('complaints')
      .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
      .orderBy("imgUID", descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
              future: fetchData(context),
              builder: (context, snapshot) {
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 50,
                      backgroundImage: profileUrl != null
                          ? NetworkImage(profileUrl!) as ImageProvider
                          : const AssetImage('assets/avatar.png'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut().then((value) =>
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => AuthScreen()),
                                        (route) => false));
                              },
                              child: const Text('LogOut'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder(
            stream: _myComplaints,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (streamSnapshot.connectionState ==
                      ConnectionState.active ||
                  streamSnapshot.connectionState == ConnectionState.done) {
                if (streamSnapshot.hasError) {
                  return const Center(
                    child: Text('Something got error'),
                  );
                } else if (streamSnapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('You didn\'t posted any complaint'),
                  );
                } else if (streamSnapshot.hasData) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return const Divider(
                        thickness: 2,
                      );
                    },
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];

                      return Container(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 10,
                          right: 10,
                        ),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        documentSnapshot['userProfile'],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        documentSnapshot['userName'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(documentSnapshot['status']),
                                    IconButton(
                                      onPressed: () async {
                                        await deletePopUp(
                                            context,
                                            documentSnapshot,
                                            streamSnapshot,
                                            index);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on),
                                    Expanded(
                                      child: Text(
                                        documentSnapshot['address'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Category: ${documentSnapshot['category']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                documentSnapshot['details'] != null
                                    ? Text(documentSnapshot['details'])
                                    : const SizedBox.shrink(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Image.network(
                                  documentSnapshot['imgURL'],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('You didn\'t posted any complaint'),
                  );
                }
              } else {
                return Center(
                  child: Text(streamSnapshot.connectionState.toString()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  deletePopUp(BuildContext context, DocumentSnapshot<Object?> documentSnapshot,
      AsyncSnapshot<QuerySnapshot<Object?>> streamSnapshot, int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Delete Complaint ?'),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey[200],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.red[500], onPrimary: Colors.white),
                    onPressed: () async {
                      final imgURL = documentSnapshot['imgURL'];

                      await FirebaseStorage.instance
                          .refFromURL(imgURL)
                          .delete();

                      await FirebaseFirestore.instance
                          .runTransaction((transaction) async {
                        transaction
                            .delete(streamSnapshot.data!.docs[index].reference);
                      });

                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  fetchData(context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usersData')
          .doc(user.uid)
          .get()
          .then((ds) {
        userName = ds.data()!['name'];
        profileUrl = ds.data()!['profileUrl'];
      }).catchError((e) {
        GlobalSnackBar.show(context, e);
      });
    }
  }
}
