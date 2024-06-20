import 'package:flutter/material.dart';

import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/screens/rest_demo.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostController controller;
  late Post post;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    controller = PostController();
    fetchPostDetails();
  }

  void fetchPostDetails() async {
    try {
      post = await controller.getPostById(widget.postId);
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(post.body),
                    ],
                  ),
                ),
    );
  }
}
