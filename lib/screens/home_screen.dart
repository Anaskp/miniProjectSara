import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final _complaints = FirebaseFirestore.instance
      .collection('complaints')
      .orderBy("imgUID", descending: true)
      .snapshots();

  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _complaints,
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (streamSnapshot.connectionState == ConnectionState.active ||
            streamSnapshot.connectionState == ConnectionState.done) {
          if (streamSnapshot.hasError) {
            return const Center(
              child: Text('Something got error'),
            );
          } else if (streamSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Complaints'),
            );
          } else if (streamSnapshot.hasData) {
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) {
                return const Divider(
                  thickness: 2,
                );
              },
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

                List likedUser = documentSnapshot['votedUser'];
                bool isLiked = likedUser.contains(_user!.email);

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
                              Text(documentSnapshot['status'])
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
                          Row(
                            children: [
                              _postButton(
                                icon: Icon(
                                  Icons.arrow_upward_sharp,
                                  color: isLiked ? Colors.red : Colors.grey,
                                ),
                                text: 'Vote ${documentSnapshot['vote']}',
                                ontap: () async {
                                  FirebaseFirestore.instance
                                      .collection('complaints')
                                      .doc(documentSnapshot.id)
                                      .update({
                                    'votedUser': [_user!.email],
                                    'vote': documentSnapshot['vote'] + 1
                                  });
                                },
                              ),
                              const VerticalDivider(
                                width: 3,
                              ),
                              _postButton(
                                  icon: const Icon(Icons.report),
                                  text: 'Report',
                                  ontap: () {}),
                            ],
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
              child: Text('No Complaints'),
            );
          }
        } else {
          return Center(
            child: Text(streamSnapshot.connectionState.toString()),
          );
        }
      },
    );
  }
}

class _postButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final VoidCallback ontap;

  const _postButton(
      {super.key, required this.icon, required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: ontap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(
                  width: 4,
                ),
                Text(
                  text,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
