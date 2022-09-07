import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _complaintsNew = FirebaseFirestore.instance
      .collection('complaints')
      .orderBy("imgUID", descending: true)
      .snapshots();

  final _complaintsMoreVote = FirebaseFirestore.instance
      .collection('complaints')
      .orderBy("vote", descending: true)
      .snapshots();

  final _user = FirebaseAuth.instance.currentUser;

  bool isFiltered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              _filter();
            },
            child: Text(
                isFiltered ? 'Filter by new complaints' : 'Filter by votes'),
          ),
          StreamBuilder(
            stream: isFiltered ? _complaintsMoreVote : _complaintsNew,
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
                    child: Text('No Complaints'),
                  );
                } else if (streamSnapshot.hasData) {
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
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
                                    _PostButton(
                                      color: isLiked ? Colors.red : Colors.grey,
                                      icon: Icon(
                                        Icons.arrow_upward_sharp,
                                        color:
                                            isLiked ? Colors.red : Colors.grey,
                                      ),
                                      text: 'Vote ${documentSnapshot['vote']}',
                                      ontap: () {
                                        isLiked
                                            ? removeLike(documentSnapshot)
                                            : addLike(documentSnapshot);
                                      },
                                    ),
                                    const VerticalDivider(
                                      width: 3,
                                    ),
                                    _PostButton(
                                        color: Colors.grey,
                                        icon: const Icon(Icons.report),
                                        text: 'Report',
                                        ontap: () {
                                          reportPost(context, documentSnapshot);
                                        }),
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
          ),
        ],
      ),
    );
  }

  Future<dynamic> reportPost(
      BuildContext context, DocumentSnapshot<Object?> documentSnapshot) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: const Color.fromARGB(255, 61, 61, 61),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReportOption(
                  documentSnapshot: documentSnapshot,
                  text: 'Wrong Category',
                ),
                const Divider(thickness: 2),
                ReportOption(
                  documentSnapshot: documentSnapshot,
                  text: 'Not a complaint',
                ),
                const Divider(thickness: 2),
                ReportOption(
                  documentSnapshot: documentSnapshot,
                  text: 'Not a public complaint',
                ),
                const Divider(thickness: 2),
                ReportOption(
                  documentSnapshot: documentSnapshot,
                  text: 'Explicit content',
                ),
              ],
            ),
          );
        });
  }

  void addLike(DocumentSnapshot documentSnapshot) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(documentSnapshot.id)
        .update({
      'votedUser': FieldValue.arrayUnion([_user!.email]),
      'vote': documentSnapshot['vote'] + 1
    });
  }

  void removeLike(DocumentSnapshot documentSnapshot) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(documentSnapshot.id)
        .update({
      'votedUser': FieldValue.arrayRemove([_user!.email]),
      'vote': documentSnapshot['vote'] - 1
    });
  }

  void _filter() {
    setState(() {
      isFiltered = !isFiltered;
    });
  }
}

class ReportOption extends StatelessWidget {
  final String text;
  final DocumentSnapshot documentSnapshot;

  const ReportOption(
      {super.key, required this.text, required this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          await FirebaseFirestore.instance
              .collection('reportedComplaints')
              .doc(documentSnapshot.id)
              .set({
            'email': documentSnapshot['email'],
            'imgUID': documentSnapshot['imgUID'],
            'imgURL': documentSnapshot['imgURL'],
            'address': documentSnapshot['address'],
            'details': documentSnapshot['details'],
            'category': documentSnapshot['category'],
            'lat': documentSnapshot['lat'],
            'long': documentSnapshot['long'],
            'status': documentSnapshot['status'],
            'userUID': documentSnapshot['userUID'],
            'userName': documentSnapshot['userName'],
            'userProfile': documentSnapshot['userProfile'],
            'vote': documentSnapshot['vote'],
            'votedUser': documentSnapshot['votedUser'],
            'reportedcategory': text,
          });

          await FirebaseFirestore.instance
              .collection('complaints')
              .doc(documentSnapshot.id)
              .delete();

          Navigator.of(context).pop();
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final VoidCallback ontap;
  final Color color;

  const _PostButton(
      {required this.icon,
      required this.text,
      required this.ontap,
      required this.color});

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
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
