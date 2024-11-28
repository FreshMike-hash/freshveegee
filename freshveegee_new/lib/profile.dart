import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        name = snapshot['name'] ?? user.displayName ?? "No Name";
        email = snapshot['email'] ?? user.email ?? "No Email";
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Log Out"),
            ),
          ],
        );
      },
    );
  }

  void _showNameEditDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Enter new name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await user.updateDisplayName(newName);
                      await user.reload();
                      user = FirebaseAuth.instance.currentUser;

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .update({'name': newName});

                      setState(() {
                        name = newName;
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Name updated successfully")),
                      );
                    }
                  } catch (e) {
                    print("Error updating name: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to update name")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid name")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  void _launchFacebook() async {
    const facebookUrl =
        'https://facebook.com/profile.php?id=61569688133226&_rdc=1&_rdr#';
    const facebookAppUrl = 'fb://page/61569688133226';

    final Uri appUrl = Uri.parse(facebookAppUrl);
    final Uri webUrl = Uri.parse(facebookUrl);

    try {
      print('Trying to launch Facebook app URL: $appUrl');
      if (await canLaunchUrl(appUrl)) {
        print('Launching Facebook app');
        await launchUrl(appUrl);
      } else {
        print('Facebook app not found. Trying web URL');
        if (await canLaunchUrl(webUrl)) {
          print('Launching web URL');
          await launchUrl(webUrl);
        } else {
          print('Could not launch either the app or web URL');
          throw 'Could not launch Facebook URL';
        }
      }
    } catch (e) {
      print('Error launching Facebook URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open Facebook page: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (authSnapshot.hasError || !authSnapshot.hasData) {
          return const Center(child: Text('Please log in'));
        }

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2A1D),
                  Color(0xFF375534),
                  Color(0xFF6B9071),
                  Color(0xFFAEC3B0),
                  Color(0xFFE3EED4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    color: Colors.white,
                    iconSize: 28,
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.13,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.white,
                            iconSize: 28,
                            onPressed: () {
                              _showNameEditDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Visit Facebook Page',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.facebook),
                            onPressed: _launchFacebook, // Open Facebook page
                            iconSize: 30,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
