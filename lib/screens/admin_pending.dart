import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_project/screens/complaint_solved_pic.dart';

class AdminPending extends StatefulWidget {
  const AdminPending({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminPending> createState() => _AdminPendingState();
}

class _AdminPendingState extends State<AdminPending> {
  String? category;
  bool isFiltered = false;
  dynamic _complaints;
  final _statusList = ['Work started', 'Work Completed'];
  String? _choosenStatus;

  Future fetchData() async {
    var data = await FirebaseFirestore.instance
        .collection('usersData')
        .doc(user!.uid)
        .get();

    setState(() {
      category = data['category'];

      _complaints = FirebaseFirestore.instance
          .collection('complaints')
          .where('category', isEqualTo: category)
          .where('track', isEqualTo: 'pending')
          .snapshots();
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: StreamBuilder(
          stream: _complaints,
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
                return const Text('Something got error');
              } else if (streamSnapshot.data!.docs.isEmpty) {
                return const Text('No Pending works');
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
                              DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton(
                                    iconSize: 35,
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(15),
                                    value: _choosenStatus,
                                    items: _statusList.map(
                                      (String value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        );
                                      },
                                    ).toList(),
                                    hint: const Text('Choose complaint status'),
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          statusChangePopUp(
                                              value, documentSnapshot);
                                          _choosenStatus = value as String?;
                                        },
                                      );
                                    },
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
      ),
    );
  }

  statusChangePopUp(status, documentSnapshot) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Update complaint status ?'),
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
                        primary: Colors.green, onPrimary: Colors.white),
                    onPressed: () async {
                      if (status == 'Work started') {
                        await FirebaseFirestore.instance
                            .collection('complaints')
                            .doc(documentSnapshot.id)
                            .update({
                          'status': status,
                        });

                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ComplaintSolvedPic(docUID: documentSnapshot.id),
                          ),
                        );
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
