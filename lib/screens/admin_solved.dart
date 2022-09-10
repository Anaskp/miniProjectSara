import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_project/widgets/map_launcher.dart';

class AdminSolved extends StatefulWidget {
  const AdminSolved({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminSolved> createState() => _AdminSolvedState();
}

class _AdminSolvedState extends State<AdminSolved> {
  String? category;
  bool isFiltered = false;
  dynamic _complaints;

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
          .where('track', isEqualTo: 'solved')
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
                return const Text('No Solved Works');
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

                    final List<String> imgList = [
                      documentSnapshot['imgURL'],
                      documentSnapshot['imgSolved']
                    ];

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
                              InkWell(
                                onTap: () {
                                  MapLauncher().showMap(documentSnapshot['lat'],
                                      documentSnapshot['long']);
                                },
                                child: Row(
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
                              CarouselSlider(
                                options: CarouselOptions(
                                    viewportFraction: 1,
                                    aspectRatio: 1.1,
                                    enableInfiniteScroll: false,
                                    scrollPhysics:
                                        const BouncingScrollPhysics()),
                                items: imgList
                                    .map(
                                      (item) => Stack(
                                        children: [
                                          Image.network(
                                            item,
                                            fit: BoxFit.contain,
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.grey[300],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Text(
                                                    '${imgList.indexOf(item) + 1} / 2'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
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
}
