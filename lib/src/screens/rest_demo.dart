import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/models/user.model.dart';
import 'package:state_change_demo/src/screens/post_details.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino

class RestDemoScreen extends StatefulWidget {
  const RestDemoScreen({super.key});

  @override
  State<RestDemoScreen> createState() => _RestDemoScreenState();
}

class _RestDemoScreenState extends State<RestDemoScreen> {
  PostController postController = PostController();
  UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    userController.getUsers().then((_) {
      postController.getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0Xff191919),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0Xff191919),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white, // Set body text color to white
          displayColor: Colors.white, // Set headline text color to white
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Users"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              userController.getUsers().then((_) {
                postController.getPosts();
              });
            },
            icon: const Icon(CupertinoIcons.refresh), // Use Cupertino icon
          ),
          actions: [
            IconButton(
              onPressed: () {
                showNewPostFunction(context);
              },
              icon: const Icon(CupertinoIcons.add), // Use Cupertino icon
            )
          ],
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: postController,
            builder: (context, _) {
              if (postController.error != null) {
                return Center(
                  child: Text(postController.error.toString()),
                );
              }

              return ListenableBuilder(
                listenable: userController,
                builder: (context, _) {
                  if (userController.error != null) {
                    return Center(
                      child: Text(userController.error.toString()),
                    );
                  }

                  if (!userController.working && !postController.working) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: userController.userList.length,
                      itemBuilder: (context, index) {
                        User user = userController.userList[index];
                        List<Post> userPosts = postController.postList
                            .where((post) => post.userId == user.id)
                            .toList();
                        return ExpansionTile(
                          title: Text(user.name),
                          children: [
                            for (Post post in userPosts)
                              PostSummaryCard(
                                post: post,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PostDetailScreen(postId: post.id),
                                    ),
                                  );
                                },
                                onEdit: () {
                                  EditPostDialog.show(context,
                                      controller: postController, post: post);
                                },
                                onDelete: () {
                                  postController.deletePost(post.id);
                                },
                              ),
                          ],
                        );
                      },
                    );
                  }
                  return const Center(
                    child: SpinKitChasingDots(
                      size: 54,
                      color:
                          Colors.white, // Change color to white for dark mode
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  showNewPostFunction(BuildContext context) {
    AddPostDialog.show(context,
        controller: postController, userController: userController);
  }
}

class AddPostDialog extends StatefulWidget {
  static show(BuildContext context,
          {required PostController controller,
          required UserController userController}) =>
      showDialog(
          context: context,
          builder: (dContext) => AddPostDialog(controller, userController));
  const AddPostDialog(this.controller, this.userController, {super.key});

  final PostController controller;
  final UserController userController;

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  late TextEditingController bodyC, titleC;
  User? selectedUser;

  @override
  void initState() {
    super.initState();
    bodyC = TextEditingController();
    titleC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850], // Dark background for dialog
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: const Text(
        "Add new post",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        ElevatedButton(
          onPressed: selectedUser == null
              ? null
              : () async {
                  widget.controller.makePost(
                      title: titleC.text.trim(),
                      body: bodyC.text.trim(),
                      userId: selectedUser!.id);
                  Navigator.of(context).pop();
                },
          child: const Text("Add"),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Title",
            style: TextStyle(color: Colors.white),
          ),
          Flexible(
            child: TextFormField(
              controller: titleC,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          const Text(
            "Content",
            style: TextStyle(color: Colors.white),
          ),
          Flexible(
            child: TextFormField(
              controller: bodyC,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          const Text(
            "User",
            style: TextStyle(color: Colors.white),
          ),
          DropdownButton<User>(
            isExpanded: true,
            value: selectedUser,
            items: widget.userController.userList.map((User user) {
              return DropdownMenuItem<User>(
                value: user,
                child: Text(
                  user.name,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            dropdownColor: Colors.grey[800],
            onChanged: (User? newValue) {
              setState(() {
                selectedUser = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }
}

class EditPostDialog extends StatefulWidget {
  static show(BuildContext context,
          {required PostController controller, required Post post}) =>
      showDialog(
          context: context,
          builder: (dContext) => EditPostDialog(controller, post));
  const EditPostDialog(this.controller, this.post, {super.key});

  final PostController controller;
  final Post post;

  @override
  State<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<EditPostDialog> {
  late TextEditingController bodyC, titleC;

  @override
  void initState() {
    super.initState();
    bodyC = TextEditingController(text: widget.post.body);
    titleC = TextEditingController(text: widget.post.title);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850], // Dark background for dialog
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: const Text(
        "Edit post",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await widget.controller.updatePost(
                postId: widget.post.id,
                title: titleC.text.trim(),
                body: bodyC.text.trim(),
                userId: widget.post.userId);
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Title",
            style: TextStyle(color: Colors.white),
          ),
          Flexible(
            child: TextFormField(
              controller: titleC,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          const Text(
            "Content",
            style: TextStyle(color: Colors.white),
          ),
          Flexible(
            child: TextFormField(
              controller: bodyC,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostController with ChangeNotifier {
  Map<String, dynamic> posts = {};
  bool working = true;
  Object? error;

  List<Post> get postList => posts.values.whereType<Post>().toList();

  clear() {
    error = null;
    posts = {};
    notifyListeners();
  }

  Future<Post> makePost(
      {required String title,
      required String body,
      required int userId}) async {
    try {
      working = true;
      if (error != null) error = null;
      print(title);
      print(body);
      print(userId);
      http.Response res = await HttpService.post(
          url: "https://jsonplaceholder.typicode.com/posts",
          body: {"title": title, "body": body, "userId": userId});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      print(res.body);

      Map<String, dynamic> result = jsonDecode(res.body);

      Post output = Post.fromJson(result);
      posts[output.id.toString()] = output;
      working = false;
      notifyListeners();
      return output;
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
      return Post.empty;
    }
  }

  Future<void> getPosts() async {
    try {
      working = true;
      clear();
      List result = [];
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/posts");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<Post> tmpPost = result.map((e) => Post.fromJson(e)).toList();
      posts = {for (Post p in tmpPost) "${p.id}": p};
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Future<Post> getPostById(int postId) async {
    try {
      working = true;
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/posts/$postId");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      Map<String, dynamic> result = jsonDecode(res.body);
      Post post = Post.fromJson(result);
      posts[post.id.toString()] = post;
      working = false;
      notifyListeners();
      return post;
    } catch (e) {
      print(e);
      working = false;
      error = e;
      notifyListeners();
      throw e;
    }
  }

  Future<Post> updatePost({
    required int postId,
    required String title,
    required String body,
    required int userId,
  }) async {
    try {
      working = true;
      if (error != null) error = null;
      notifyListeners();

      http.Response res = await HttpService.put(
        url: "https://jsonplaceholder.typicode.com/posts/$postId",
        body: {"title": title, "body": body, "userId": userId},
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      Map<String, dynamic> result = jsonDecode(res.body);
      Post updatedPost = Post.fromJson(result);
      posts[updatedPost.id.toString()] = updatedPost;
      working = false;
      notifyListeners();
      return updatedPost;
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
      return Post.empty;
    }
  }

  Future<void> deletePost(int postId) async {
    posts.remove(postId.toString());
    notifyListeners();
  }
}

class UserController with ChangeNotifier {
  Map<String, dynamic> users = {};
  bool working = true;
  Object? error;

  List<User> get userList => users.values.whereType<User>().toList();

  getUsers() async {
    try {
      working = true;
      List result = [];
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/users");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<User> tmpUser = result.map((e) => User.fromJson(e)).toList();
      users = {for (User u in tmpUser) "${u.id}": u};
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  clear() {
    users = {};
    notifyListeners();
  }
}

class HttpService {
  static Future<http.Response> get(
      {required String url, Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> post(
      {required String url,
      required Map<dynamic, dynamic> body,
      Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.post(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> put({
    required String url,
    required Map<dynamic, dynamic> body,
    Map<String, dynamic>? headers,
  }) async {
    Uri uri = Uri.parse(url);
    return http.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }
}

class PostSummaryCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PostSummaryCard({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Color(0xff292929), // Dark card background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for dark mode
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    color: Colors.grey[850],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.body,
                style: const TextStyle(
                    color: Color(0xffAAAAAA)), // Slightly lighter text color
              ),
            ],
          ),
        ),
      ),
    );
  }
}
