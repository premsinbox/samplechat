import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:samplechat/Chat/Chat_page.dart';
import 'package:samplechat/Profile/Profile_page.dart'; // Import the ProfilePage

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTap(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sample Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildUsersList(),
          ProfilePage(), // Profile Page
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        List<UserTile> userTiles = [];

        for (var user in users) {
          final userData = user.data() as Map<String, dynamic>;
          final userEmail = userData['email'];
          final username = userData['username'];
          final profilePicUrl = userData['profilePicUrl'] ?? '';

          if (userEmail != FirebaseAuth.instance.currentUser!.email) {
            final userTile = UserTile(
              email: userEmail,
              username: username,
              profilePicUrl: profilePicUrl,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(peerEmail: userEmail),
                  ),
                );
              },
            );
            userTiles.add(userTile);
          }
        }

        return ListView(
          children: userTiles,
        );
      },
    );
  }
}

class UserTile extends StatelessWidget {
  final String email;
  final String username;
  final String profilePicUrl;
  final VoidCallback onTap;

  UserTile({
    required this.email,
    required this.username,
    required this.profilePicUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: profilePicUrl.isNotEmpty
                ? NetworkImage(profilePicUrl)
                : AssetImage('assets/profiledp.jpg') as ImageProvider,
          ),
          title: Text(username),
          subtitle: Text(email),
          onTap: onTap,
        ),
        Divider(color: Colors.white),
      ],
    );
  }
}
