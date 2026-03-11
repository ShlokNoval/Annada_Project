import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'create_post_page.dart'; // 🔥 NEW IMPORT

class CommunityFeedPage extends StatelessWidget {
  const CommunityFeedPage({super.key});

  String _formatTime(BuildContext context, Timestamp? timestamp) {
    final l10n = AppLocalizations.of(context)!;

    if (timestamp == null) return "";
    final date = timestamp.toDate();
    final difference = DateTime.now().difference(date);

    if (difference.inSeconds < 60) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return l10n.daysAgo(difference.inDays);
    }
  }

  void _showCommentSheet(BuildContext context, String postId) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController commentController =
    TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(l10n.comments,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
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
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data!.docs;

                  if (comments.isEmpty) {
                    return Center(
                        child: Text(l10n.noCommentsYet));
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (_, index) {
                      final data = comments[index].data()
                      as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["authorName"] ??
                                  l10n.farmer,
                              style: const TextStyle(
                                  fontWeight:
                                  FontWeight.bold),
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
            Padding(
              padding: EdgeInsets.only(
                bottom:
                MediaQuery.of(context).viewInsets.bottom,
                left: 12,
                right: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                          hintText: l10n.writeReply),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.green),
                    onPressed: () async {
                      if (commentController.text
                          .trim()
                          .isEmpty) return;

                      await FirebaseFirestore.instance
                          .collection("posts")
                          .doc(postId)
                          .collection("comments")
                          .add({
                        "text":
                        commentController.text.trim(),
                        "authorId":
                        FirebaseAuth.instance
                            .currentUser
                            ?.uid,
                        "authorName":
                        FirebaseAuth.instance
                            .currentUser
                            ?.displayName ??
                            l10n.farmer,
                        "timestamp":
                        FieldValue.serverTimestamp(),
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
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirebaseFirestore.instance;
    final currentUser =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communityTitle),
        backgroundColor: Colors.green,
      ),

      // 🔥 FAB NOW OPENS IMAGE CREATE PAGE
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("posts")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return Center(
                child: Text(l10n.noPostsYet));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, index) {
              final doc = posts[index];
              final data =
              doc.data() as Map<String, dynamic>;

              final isOwner =
                  currentUser?.uid ==
                      data["authorId"];

              final imageUrl =
                  data["imageUrl"] ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6),
                child: Padding(
                  padding:
                  const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      // HEADER
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                data["authorName"] ??
                                    l10n.farmer,
                                style:
                                const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold),
                              ),
                              Text(
                                _formatTime(
                                    context,
                                    data[
                                    "timestamp"]),
                                style:
                                const TextStyle(
                                    fontSize:
                                    12,
                                    color: Colors
                                        .grey),
                              ),
                            ],
                          ),
                          if (isOwner)
                            PopupMenuButton(
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                    value: "delete",
                                    child: Text(
                                        l10n.delete)),
                              ],
                              onSelected:
                                  (value) async {
                                if (value ==
                                    "delete") {
                                  await firestore
                                      .collection(
                                      "posts")
                                      .doc(doc.id)
                                      .delete();
                                }
                              },
                            )
                        ],
                      ),

                      const SizedBox(height: 8),

                      // TEXT
                      if (data["text"] != null &&
                          data["text"] != "")
                        Text(data["text"]),

                      const SizedBox(height: 8),

                      // 🔥 IMAGE DISPLAY
                      if (imageUrl != null &&
                          imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(
                              12),
                          child: Image.network(
                            imageUrl,
                            width:
                            double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      const SizedBox(height: 10),

                      // LIKE + COMMENT
                      Row(
                        children: [

                          // LIKE
                          StreamBuilder<
                              DocumentSnapshot>(
                            stream: firestore
                                .collection("posts")
                                .doc(doc.id)
                                .collection("likes")
                                .doc(currentUser
                                ?.uid ??
                                "")
                                .snapshots(),
                            builder:
                                (_, likeSnap) {
                              final isLiked =
                                  likeSnap.data
                                      ?.exists ??
                                      false;

                              int likes =
                                  data["likesCount"] ??
                                      0;

                              return Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked
                                          ? Icons
                                          .favorite
                                          : Icons
                                          .favorite_border,
                                      color: isLiked
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed:
                                        () async {
                                      final postRef =
                                      firestore
                                          .collection(
                                          "posts")
                                          .doc(doc.id);

                                      final likeRef =
                                      postRef
                                          .collection(
                                          "likes")
                                          .doc(currentUser
                                          ?.uid);

                                      final snap =
                                      await postRef
                                          .get();

                                      int currentLikes =
                                          snap[
                                          "likesCount"] ??
                                              0;

                                      if (isLiked) {
                                        if (currentLikes >
                                            0) {
                                          await likeRef
                                              .delete();
                                          await postRef
                                              .update({
                                            "likesCount":
                                            currentLikes -
                                                1
                                          });
                                        }
                                      } else {
                                        await likeRef
                                            .set({
                                          "likedAt":
                                          FieldValue
                                              .serverTimestamp()
                                        });
                                        await postRef
                                            .update({
                                          "likesCount":
                                          currentLikes +
                                              1
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

                          // COMMENT
                          IconButton(
                            icon: const Icon(
                                Icons.comment,
                                color:
                                Colors.grey),
                            onPressed: () =>
                                _showCommentSheet(
                                    context,
                                    doc.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}