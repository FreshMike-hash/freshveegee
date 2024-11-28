import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Please log in to see the dashboard")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE3EED4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2A1D),
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('scanned')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var freshCount = 0;
                var staleCount = 0;

                // Calculate the count of fresh and stale fruits
                for (var doc in snapshot.data!.docs) {
                  var condition = doc['condition'];
                  if (condition == 'Fresh') {
                    freshCount++;
                  } else if (condition == 'Stale') {
                    staleCount++;
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2A1D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              freshCount.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Fresh",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF375534),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staleCount.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Stale",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('scanned')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var scannedFruits = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: scannedFruits.length,
                    itemBuilder: (context, index) {
                      var doc = scannedFruits[index];
                      String docId = doc.id; // Get the document ID
                      String date = doc['date'];
                      String time = doc['time'];
                      String fruitType = doc['fruit_type'];
                      String condition = doc['condition'];

                      return Dismissible(
                        key: Key(docId),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          // Show confirmation dialog before deleting
                          bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Deletion"),
                                content: const Text(
                                    "Are you sure you want to delete this entry?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            // Delete the document from Firestore if confirmed
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('scanned')
                                .doc(docId)
                                .delete();

                            // Show snackbar for success
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Item deleted successfully"),
                              ),
                            );
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              fruitType,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Date: $date",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Time: $time",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Condition: $condition",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: condition == "Fresh"
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
