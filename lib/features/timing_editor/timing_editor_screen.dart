import 'package:flutter/material.dart';
import 'package:jamat_timings/core/constants.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:jamat_timings/data/models/prayer_timing.dart';

class TimingEditorScreen extends StatefulWidget {
  final String masjidId;

  const TimingEditorScreen({super.key, required this.masjidId});

  @override
  State<TimingEditorScreen> createState() => _TimingEditorScreenState();
}

class _TimingEditorScreenState extends State<TimingEditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PrayerTiming> _timings = [];

  final List<String> _prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'jumuah'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _prayers.length, vsync: this);
    _timings = List.from(MockData.timings[widget.masjidId] ?? []);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addOrEditTime(String prayer, [PrayerTiming? existingTiming]) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: existingTiming != null
          ? TimeOfDay(
              hour: int.parse(existingTiming.jamatTime.split(':')[0]),
              minute: int.parse(existingTiming.jamatTime.split(':')[1]),
            )
          : const TimeOfDay(hour: 12, minute: 0),
    );

    if (selectedTime == null || !mounted) return;

    final String timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

    setState(() {
      if (existingTiming != null) {
        final index = _timings.indexWhere((t) => t.id == existingTiming.id);
        if (index != -1) {
          _timings[index] = existingTiming.copyWith(
            jamatTime: timeStr,
            updatedAt: DateTime.now(),
          );
        }
      } else {
        final newId = 't_new_${DateTime.now().millisecondsSinceEpoch}';
        _timings.add(
          PrayerTiming(
            id: newId,
            masjidId: widget.masjidId,
            prayer: prayer,
            jamatTime: timeStr,
            isRamadan: false,
            updatedAt: DateTime.now(),
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timing updated locally (save to publish).')),
    );
  }

  void _deleteTiming(String id) {
    setState(() {
      _timings.removeWhere((t) => t.id == id);
    });
  }

  void _saveChanges() {
    MockData.timings[widget.masjidId] = _timings;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changes Published'),
        content: const Text('New Jamat timings have been successfully synchronized with the cloud backend.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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

    final masjid = MockData.masjids.firstWhere(
      (m) => m.id == widget.masjidId,
      orElse: () => MockData.masjids[0],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${masjid.name} Timings', style: theme.textTheme.titleLarge),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _prayers.map((prayer) {
            final displayName = AppConstants.prayerDisplayNames[prayer] ?? prayer;
            return Tab(text: displayName.toUpperCase());
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _prayers.map((prayer) {
          final prayerTimings = _timings.where((t) => t.prayer.toLowerCase() == prayer).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Congregation (${prayer.toUpperCase()}) Times',
                      style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add, size: 16, color: colorScheme.onPrimary),
                      label: const Text('Add Time'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _addOrEditTime(prayer),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: prayerTimings.isEmpty
                      ? Center(child: Text('No congregation times configured.', style: theme.textTheme.bodyMedium))
                      : ListView.builder(
                          itemCount: prayerTimings.length,
                          itemBuilder: (context, index) {
                            final timing = prayerTimings[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(Icons.access_time, color: colorScheme.primary),
                                title: Text(timing.jamatTime, style: theme.textTheme.titleMedium),
                                subtitle: Text(timing.label ?? 'Standard Jamat'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: colorScheme.primary),
                                      onPressed: () => _addOrEditTime(prayer, timing),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: colorScheme.error),
                                      onPressed: () => _deleteTiming(timing.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('PUBLISH CHANGES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}
