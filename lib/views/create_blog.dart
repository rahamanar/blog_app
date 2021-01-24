import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class CreateBlog extends StatefulWidget {
  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  File _selectedImage;
  final picker = ImagePicker();
  String imageUrl;
  bool isloading = false;

  TextEditingController authortextcontroller = TextEditingController();
  TextEditingController titletextcontroller = TextEditingController();
  TextEditingController desctextcontroller = TextEditingController();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  addBlog() async {
    if (_selectedImage != null) {
      // upload image
      FirebaseStorage storage = FirebaseStorage.instance;

      Reference reference =
          storage.ref().child("/blogImages/${randomAlphaNumeric(20)}.jpg");

      UploadTask uploadTask = reference.putFile(_selectedImage);

      await uploadTask.whenComplete(() async {
        try {
          // get download url
          imageUrl = await reference.getDownloadURL();
        } catch (e) {
          print(e);
        }
      });

      Map<String, dynamic> blogData = {
        "author": authortextcontroller.text,
        "desc": desctextcontroller.text,
        "title": titletextcontroller.text,
        "imgUrl": imageUrl,
        "time": DateTime.now().millisecond
      };

      // upload to firebase
      FirebaseFirestore.instance
          .collection("blogs")
          .add(blogData)
          .catchError((onError) {
        print("Facing issue while uploading : $onError");
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Blog"),
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: _selectedImage == null
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 16),
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8)),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage,
                                fit: BoxFit.cover,
                                height: 180,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                    ),
                    TextField(
                      controller: authortextcontroller,
                      decoration: InputDecoration(hintText: "author name"),
                    ),
                    TextField(
                      controller: titletextcontroller,
                      decoration: InputDecoration(hintText: "title"),
                    ),
                    TextField(
                      controller: desctextcontroller,
                      decoration: InputDecoration(hintText: "description"),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addBlog();
        },
        child: Icon(Icons.file_upload),
      ),
    );
  }
}
