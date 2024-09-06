import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String peerEmail;

  ChatScreen({required this.peerEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.isNotEmpty) {
      setState(() {
        _isSending = true;
      });

      String chatId = getChatRoomId(loggedInUser!.email!, widget.peerEmail);
      await _firestore.collection('chats/$chatId/messages').add({
        'text': message,
        'sender': loggedInUser?.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> sendImageOrVideo({required bool isVideo}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isSending = true;
      });

      File file = File(pickedFile.path);
      final fileName = pickedFile.path.split('/').last;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(isVideo ? 'chat_videos/$fileName' : 'chat_images/$fileName');
      await storageRef.putFile(file);
      String fileUrl = await storageRef.getDownloadURL();

      String chatId = getChatRoomId(loggedInUser!.email!, widget.peerEmail);
      await _firestore.collection('chats/$chatId/messages').add({
        isVideo ? 'videoUrl' : 'imageUrl': fileUrl,
        'sender': loggedInUser?.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSending = false;
      });
    }
  }

  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.peerEmail}'),
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: MessagesStream(
                chatId: getChatRoomId(loggedInUser!.email!, widget.peerEmail)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () => sendImageOrVideo(isVideo: false),
                ),
                IconButton(
                  icon: _isSending
                      ? CircularProgressIndicator()
                      : Icon(Icons.send),
                  onPressed: () => sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String chatId;

  MessagesStream({required this.chatId});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats/$chatId/messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageData = message.data() as Map<String, dynamic>?;
          final messageText = messageData?['text'];
          final messageSender = messageData?['sender'];
          final messageImageUrl = messageData?.containsKey('imageUrl') == true
              ? messageData!['imageUrl']
              : null;
          final messageVideoUrl = messageData?.containsKey('videoUrl') == true
              ? messageData!['videoUrl']
              : null;
          final messageTimestamp = messageData?['timestamp'] as Timestamp?;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            imageUrl: messageImageUrl,
            videoUrl: messageVideoUrl,
            isSender: currentUser?.email == messageSender,
            timestamp: messageTimestamp,
          );
          messageBubbles.add(messageBubble);
        }

        return ListView(
          reverse: true,
          children: messageBubbles,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String? sender;
  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final bool isSender;
  final Timestamp? timestamp;

  MessageBubble(
      {this.sender,
      this.text,
      this.imageUrl,
      this.videoUrl,
      required this.isSender,
      this.timestamp});

  @override
  Widget build(BuildContext context) {
    String formattedTime = timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp!.millisecondsSinceEpoch)
            .toLocal()
            .toString()
            .substring(11, 16)
        : '';

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender ?? 'Unknown',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment:
                isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (imageUrl != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSender ? Colors.blueAccent : Colors.grey[300],
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                )
              else if (videoUrl != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSender ? Colors.blueAccent : Colors.grey[300],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to a video player screen or play video
                    },
                    child: Icon(Icons.play_circle_filled,
                        size: 150, color: Colors.white),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: isSender ? Colors.blueAccent : Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft:
                          isSender ? Radius.circular(12) : Radius.circular(0),
                      bottomRight:
                          isSender ? Radius.circular(0) : Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    text ?? '',
                    style: TextStyle(
                      color: isSender ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            formattedTime,
            style: TextStyle(fontSize: 10, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
