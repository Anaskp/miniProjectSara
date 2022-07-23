import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:mini_project/models/complain_model.dart';
import 'package:mini_project/models/solved_model.dart';

class SolvedScreen extends StatelessWidget {
  const SolvedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Solved issues',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) {
              return const Divider(
                thickness: 2,
              );
            },
            itemCount: data.length,
            itemBuilder: (context, index) {
              final width = MediaQuery.of(context).size.width;

              final user = solvedData[index];
              final List<String> imgList = [user.image, user.solvedImage];
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
                                user.userImg,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(user.userName),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        user.caption != null
                            ? Text(user.caption!)
                            : const SizedBox.shrink(),
                        const SizedBox(
                          height: 10,
                        ),
                        CarouselSlider(
                          options: CarouselOptions(
                              viewportFraction: 1,
                              aspectRatio: 1.1,
                              enableInfiniteScroll: false,
                              scrollPhysics: const BouncingScrollPhysics()),
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
                                          padding: const EdgeInsets.all(5),
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
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
