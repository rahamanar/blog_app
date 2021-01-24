import 'package:blog_app_ar/views/create_blog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    Widget blogList() {
      return Container(
          child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("blogs")
            .orderBy("time", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Error ${snapshot.error}");
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: Text("Loading...."));
              break;

            default:
              return snapshot.hasData
                  ? ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return BlogTile(
                          imgUrl: snapshot.data.docs[index]["imgUrl"],
                          title: snapshot.data.docs[index]["title"],
                          desc: snapshot.data.docs[index]["desc"],
                          authorName: snapshot.data.docs[index]["author"],
                        );
                      },
                    )
                  : Center(child: Text("No data yet"));
          }
        },
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Blog App"),
      ),
      body: Container(
        child: blogList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateBlog(),
              ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class BlogTile extends StatelessWidget {
  final String imgUrl, title, desc, authorName;

  const BlogTile({Key key, this.imgUrl, this.title, this.desc, this.authorName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 12,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imgUrl,
            height: 180,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: 6,
        ),
        Text(title, style: TextStyle(fontSize: 17)),
        SizedBox(height: 3),
        Text("$desc by $authorName"),
        SizedBox(height: 16),
      ],
    ));
  }
}
