import 'package:flutter/material.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:jamat_timings/data/models/masjid_request.dart';

class ApprovalQueueScreen extends StatefulWidget {
  const ApprovalQueueScreen({super.key});

  @override
  State<ApprovalQueueScreen> createState() => _ApprovalQueueScreenState();
}

class _ApprovalQueueScreenState extends State<ApprovalQueueScreen> {
  List<MasjidRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _requests = List.from(MockData.pendingRequests);
  }

  void _handleApproval(MasjidRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request?'),
        content: Text('This will activate "${request.masjidName}" on the public app and send invitation links to: ${request.adminEmail}.'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text('Approve', style: TextStyle(color: Colors.green)),
            onPressed: () {
              setState(() {
                _requests.removeWhere((r) => r.id == request.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully onboarded: ${request.masjidName}')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleRejection(MasjidRequest request) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Specify reason for declining "${request.masjidName}":'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: 'e.g. Incomplete details, duplicate entry...'),
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                _requests.removeWhere((r) => r.id == request.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Request rejected for: ${request.masjidName}')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Queue', style: TextStyle(fontFamily: 'Amiri')),
        actions: [
          // Quick logout back to guest
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: _requests.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('All Caught Up!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                  SizedBox(height: 8),
                  Text('No pending masjid registration requests.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.rate_review, color: AppTheme.primaryGreen),
                    title: Text(request.masjidName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${request.city} • Submitter: ${request.adminEmail}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            _buildInfoRow('Address', request.address),
                            _buildInfoRow('Area', request.area ?? 'None specified'),
                            _buildInfoRow('Imam Name', request.imamName ?? 'None specified'),
                            _buildInfoRow('Notes', request.note ?? 'No notes included.'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.clear, color: Colors.red),
                                  label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                  onPressed: () => _handleRejection(request),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check, color: Colors.white),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                                  onPressed: () => _handleApproval(request),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
