import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CommunityFeedPage extends StatelessWidget {
  const CommunityFeedPage({super.key});

  // 🔥 Format Timestamp
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    final difference = DateTime.now().difference(date);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hr ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  // 🔥 Create Post
  void _showCreatePostSheet(BuildContext context) {
    final TextEditingController postController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: postController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "What's happening in your farm?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (postController.text.trim().isEmpty) return;

                final user = FirebaseAuth.instance.currentUser;
                final prefs = await SharedPreferences.getInstance();
                final userName = prefs.getString('userName') ?? "Farmer";

                await FirebaseFirestore.instance.collection("posts").add({
                  "text": postController.text.trim(),
                  "authorId": user?.uid,
                  "authorName": userName,
                  "timestamp": FieldValue.serverTimestamp(),
                  "likesCount": 0,
                });

                postController.clear();
                Navigator.pop(context);
              },
              child: const Text("Post", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔥 Comment Sheet
  void _showCommentSheet(BuildContext context, String postId) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Comments",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),

            // Comment List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .doc(postId)
                    .collection("comments")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data!.docs;

                  if (comments.isEmpty) {
                    return const Center(child: Text("No comments yet 🌾"));
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (_, index) {
                      final data =
                      comments[index].data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["authorName"] ?? "Farmer",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(data["text"] ?? ""),
                            const Divider(),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Add Comment Input
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 12,
                right: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration:
                      const InputDecoration(hintText: "Write a reply..."),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () async {
                      if (commentController.text.trim().isEmpty) return;

                      final prefs =
                      await SharedPreferences.getInstance();
                      final userName =
                          prefs.getString('userName') ?? "Farmer";

                      await FirebaseFirestore.instance
                          .collection("posts")
                          .doc(postId)
                          .collection("comments")
                          .add({
                        "text": commentController.text.trim(),
                        "authorId":
                        FirebaseAuth.instance.currentUser?.uid,
                        "authorName": userName,
                        "timestamp": FieldValue.serverTimestamp(),
                      });

                      commentController.clear();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Annada Community 🌾"),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showCreatePostSheet(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("posts")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(child: Text("No posts yet 🌾"));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, index) {
              final doc = posts[index];
              final data = doc.data() as Map<String, dynamic>;
              final isOwner =
                  currentUser?.uid == data["authorId"];

              int likes = data["likesCount"] ?? 0;
              if (likes < 0) likes = 0;

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        // Header
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["authorName"] ?? "Farmer",
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                Text(
                                  _formatTime(data["timestamp"]),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                            if (isOwner)
                              PopupMenuButton(
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                      value: "delete",
                                      child: Text("Delete")),
                                ],
                                onSelected: (value) async {
                                  if (value == "delete") {
                                    await firestore
                                        .collection("posts")
                                        .doc(doc.id)
                                        .delete();
                                  }
                                },
                              )
                          ],
                        ),

                        const SizedBox(height: 8),
                        Text(data["text"] ?? ""),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            // LIKE
                            StreamBuilder<DocumentSnapshot>(
                              stream: firestore
                                  .collection("posts")
                                  .doc(doc.id)
                                  .collection("likes")
                                  .doc(currentUser?.uid ?? "")
                                  .snapshots(),
                              builder: (_, likeSnap) {

                                final isLiked =
                                    likeSnap.data?.exists ?? false;

                                return Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isLiked
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () async {
                                        final postRef =
                                        firestore.collection("posts").doc(doc.id);
                                        final likeRef =
                                        postRef.collection("likes").doc(currentUser?.uid);

                                        final snap =
                                        await postRef.get();
                                        int currentLikes =
                                            snap["likesCount"] ?? 0;

                                        if (isLiked) {
                                          if (currentLikes > 0) {
                                            await likeRef.delete();
                                            await postRef.update({
                                              "likesCount":
                                              currentLikes - 1
                                            });
                                          }
                                        } else {
                                          await likeRef.set({
                                            "likedAt":
                                            FieldValue.serverTimestamp()
                                          });
                                          await postRef.update({
                                            "likesCount":
                                            currentLikes + 1
                                          });
                                        }
                                      },
                                    ),
                                    Text("$likes"),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(width: 20),

                            // COMMENT COUNT
                            StreamBuilder<QuerySnapshot>(
                              stream: firestore
                                  .collection("posts")
                                  .doc(doc.id)
                                  .collection("comments")
                                  .snapshots(),
                              builder: (_, commentSnap) {
                                int count =
                                    commentSnap.data?.docs.length ?? 0;

                                return Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.comment,
                                          color: Colors.grey),
                                      onPressed: () =>
                                          _showCommentSheet(
                                              context, doc.id),
                                    ),
                                    Text("$count"),
                                  ],
                                );
                              },
                            ),
                          ],
                        )
                      ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}