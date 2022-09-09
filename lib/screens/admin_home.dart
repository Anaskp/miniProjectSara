import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String? category;
  bool isFiltered = false;
  dynamic _complaintsNew;
  dynamic _complaintsMoreVote;

  Future fetchData() async {
    var data = await FirebaseFirestore.instance
        .collection('usersData')
        .doc(user!.uid)
        .get();

    setState(() {
      category = data['category'];

      _complaintsNew = FirebaseFirestore.instance
          .collection('complaints')
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'Complaint Registerd')
          .orderBy("imgUID", descending: true)
          .snapshots();

      _complaintsMoreVote = FirebaseFirestore.instance
          .collection('complaints')
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'Complaint Registerd')
          .orderBy("vote", descending: true)
          .snapshots();
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  final user = FirebaseAuth.instance.currentUser;

  void _filter() {
    setState(() {
      isFiltered = !isFiltered;
    });
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
                return const CircularProgressIndicator();
              } else if (streamSnapshot.connectionState ==
                      ConnectionState.active ||
                  streamSnapshot.connectionState == ConnectionState.done) {
                if (streamSnapshot.hasError) {
                  return const Center(child: Text('Something got error'));
                } else if (streamSnapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No new registerd complaints'));
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
                                Material(
                                  child: InkWell(
                                    onTap: () {
                                      proceedComplaint(documentSnapshot);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      height: 40,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Proceed',
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Icon(Icons.arrow_forward),
                                        ],
                                      ),
                                    ),
                                  ),
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

  proceedComplaint(DocumentSnapshot documentSnapshot) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(documentSnapshot.id)
        .update({
      'track': 'pending',
      'status': 'Complaint proceeding started',
    });
  }
}
