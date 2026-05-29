import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
            child: Text('Approve', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
            child: Text('Reject', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Approval Queue', style: theme.textTheme.titleLarge),
        actions: [
          // Quick logout back to guest
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 64, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('All Caught Up!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text('No pending masjid registration requests.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
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
                    leading: Icon(Icons.rate_review, color: colorScheme.primary),
                    title: Text(request.masjidName, style: theme.textTheme.titleMedium),
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
                                  icon: Icon(Icons.clear, color: colorScheme.error),
                                  label: Text('Reject', style: TextStyle(color: colorScheme.error)),
                                  onPressed: () => _handleRejection(request),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.check, color: colorScheme.onPrimary),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
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
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
