import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class PoliceDashboardScreen extends StatefulWidget {
  const PoliceDashboardScreen({super.key});

  @override
  State<PoliceDashboardScreen> createState() => _PoliceDashboardScreenState();
}

class _PoliceDashboardScreenState extends State<PoliceDashboardScreen> {
  // ADD THIS FUNCTION HERE 👇
  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Control Room'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reports')
                .snapshots(),
            builder: (context, snapshot) {
              int total = 0;
              int pending = 0;
              int resolved = 0;

              if (snapshot.hasData) {
                total = snapshot.data!.docs.length;
                pending = snapshot.data!.docs
                    .where((doc) => doc['status'] == 'pending')
                    .length;
                resolved = snapshot.data!.docs
                    .where((doc) => doc['status'] == 'resolved')
                    .length;
              }

              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStatCard('Total', total.toString(), Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Pending',
                      pending.toString(),
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Resolved',
                      resolved.toString(),
                      Colors.green,
                    ),
                  ],
                ),
              );
            },
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Resolved', 'resolved'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Reports List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var reports = snapshot.data!.docs;

                if (_selectedFilter != 'all') {
                  reports = reports.where((doc) {
                    return doc['status'] == _selectedFilter;
                  }).toList();
                }

                if (reports.isEmpty) {
                  return const Center(child: Text('No reports found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    var report = reports[index].data() as Map<String, dynamic>;
                    var docId = reports[index].id;
                    return _buildReportCard(report, docId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, String docId) {
    List<String> imageUrls = List<String>.from(report['images'] ?? []);

    print('Report images: ${report['images']}');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(report['category'] ?? 'Unknown'),
        subtitle: Text('By: ${report['userEmail']}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(report['description'] ?? 'No description'),
                const SizedBox(height: 12),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text(report['address'] ?? 'No location')),
                  ],
                ),
                const SizedBox(height: 12),

                // SHOW IMAGES - ADD THIS SECTION
                if (imageUrls.isNotEmpty) ...[
                  const Text(
                    'Evidence Images:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.black,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: InteractiveViewer(
                                      child: Image.network(imageUrls[index]),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              imageUrls[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey,
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Resolve Button
                ElevatedButton(
                  onPressed: () => _updateStatus(docId, 'resolved'),
                  child: const Text('Mark Resolved'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString().substring(0, 16);
    }
    return 'Unknown time';
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance.collection('reports').doc(docId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Report marked as $status')));
  }
}
