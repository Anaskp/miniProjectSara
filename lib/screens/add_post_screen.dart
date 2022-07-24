import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:mini_project/screens/screens.dart';
import 'package:mini_project/widgets/snackbar.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  String? _userName;
  String? _userProfile;

  @override
  void initState() {
    pickImage();
    _getCurrentPosition();
    super.initState();
  }

  bool _errorMessage = false;
  LocationData? _locationData;
  File? image;
  String? _currentAddress;
  LocationData? currentLocation;
  Location location = Location();
  double? lat;
  double? long;
  String? _choosenCategory;

  final TextEditingController _detailsController = TextEditingController();

  final _categoryLiist = ['Road', 'Waste', 'Hotel cleanness'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SARA'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
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
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _currentAddress ?? 'Get your location',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _getCurrentPosition();
                        },
                        icon: const Icon(Icons.gps_fixed),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                _currentAddress == null && _errorMessage == true
                    ? Column(
                        children: const [
                          Text(
                            'Please select location',
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
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 5,
                  ),
                  width: double.infinity,
                  child: Center(
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton(
                            iconSize: 35,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(15),
                            value: _choosenCategory,
                            items: _categoryLiist.map((String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            hint: const Text('Choose category'),
                            onChanged: (value) {
                              setState(() {
                                _choosenCategory = value as String?;
                              });
                            }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                _choosenCategory == null && _errorMessage == true
                    ? Column(
                        children: const [
                          Text(
                            'Please choose a category',
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
                Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: _detailsController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Details (optional)',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                FutureBuilder(
                  future: fetchData(context),
                  builder: (context, snapshot) {
                    return SizedBox(
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitComplaint() async {
    setState(() {
      _errorMessage = true;
    });

    if (image != null && _currentAddress != null && _choosenCategory != null) {
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
        final profileRef = storageRef.child("complaints/$id");
        UploadTask uploadTask = profileRef.putFile(image!);
        String url = await (await uploadTask).ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('complaints').doc(id).set({
          'email': user.email,
          'imgUID': id,
          'imgURL': url,
          'address': _currentAddress,
          'details': _detailsController.text,
          'category': _choosenCategory,
          'lat': lat,
          'long': long,
          'status': 'Complaint Registerd',
          'userUID': user.uid,
          'userName': _userName,
          'userProfile': _userProfile,
          'vote': 0,
          'votedUser': [],
        });
        postValid = true;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false);
      } catch (e) {
        GlobalSnackBar(text: e.toString());
      }

      if (postValid == false) Navigator.of(context).pop();
    }
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

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission == PermissionStatus.denied) {
        GlobalSnackBar(text: 'Location permissions are denied');
        return false;
      }
    }
    if (permission == PermissionStatus.deniedForever) {
      GlobalSnackBar(
          text:
              'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;

    _locationData = await location.getLocation();
    lat = _locationData!.latitude;
    long = _locationData!.longitude;

    _getAddressFromLatLng(_locationData!.latitude, _locationData!.longitude);
  }

  Future<void> _getAddressFromLatLng(double? lat, double? lon) async {
    List<geocode.Placemark> placemark =
        await geocode.placemarkFromCoordinates(lat!, lon!);

    setState(() {
      _currentAddress =
          '${placemark[0].street} ${placemark[0].subLocality} ${placemark[0].locality}';
    });
  }

  fetchData(context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usersData')
          .doc(user.uid)
          .get()
          .then((ds) {
        _userName = ds.data()!['name'];
        _userProfile = ds.data()!['profileUrl'];
      }).catchError((e) {
        GlobalSnackBar.show(context, e);
      });
    }
  }
}
