import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JamatDashboardScreen extends StatefulWidget {
  const JamatDashboardScreen({super.key});

  @override
  State<JamatDashboardScreen> createState() => _JamatDashboardScreenState();
}

class _JamatDashboardScreenState extends State<JamatDashboardScreen>
    with TickerProviderStateMixin {
  static const String _mosqueNameKey = 'dashboard_mosque_name';
  static const String _prayersKey = 'dashboard_prayers';
  static const String _noticesKey = 'dashboard_notices';

  final TextEditingController _mosqueController = TextEditingController();
  final TextEditingController _noticeTitleController = TextEditingController();
  final TextEditingController _noticeBodyController = TextEditingController();

  final List<String> _noticeTags = const [
    'Announcement',
    'Circle',
    'Donation',
    'Youth',
    'General',
  ];

  String _selectedNoticeTag = 'Announcement';

  final List<HadithEntry> _hadiths = const [
    HadithEntry(
      arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      english:
          'Actions are judged by intentions, and every person will get what they intended.',
      source: 'Sahih al-Bukhari 1',
    ),
    HadithEntry(
      arabic: 'الرَّاحِمُونَ يَرْحَمُهُمُ الرَّحْمٰنُ',
      english:
          'The merciful are shown mercy by the Most Merciful. Show mercy to those on earth.',
      source: 'Jami` at-Tirmidhi 1924',
    ),
    HadithEntry(
      arabic: 'الدِّينُ النَّصِيحَةُ',
      english:
          'Religion is sincerity and sincere counsel. The believer is a mirror to the believer.',
      source: 'Sahih Muslim 55',
    ),
  ];

  late SharedPreferences _prefs;
  late DateTime _now;
  late final AnimationController _pulseController;

  Timer? _clockTimer;
  Timer? _hadithTimer;
  bool _loaded = false;
  bool _editMosqueName = false;
  bool _noticeDrawerOpen = false;
  int _hadithIndex = 0;
  int _tickCount = 0;

  List<PrayerSession> _prayers = PrayerSession.defaults();
  List<BulletinNotice> _notices = BulletinNotice.defaults();

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _prefs = await SharedPreferences.getInstance();
    _mosqueController.text =
        _prefs.getString(_mosqueNameKey) ?? 'Al-Noor Islamic Center';
    _prayers =
        PrayerSession.fromJsonList(_prefs.getString(_prayersKey)) ?? PrayerSession.defaults();
    _notices =
        BulletinNotice.fromJsonList(_prefs.getString(_noticesKey)) ?? BulletinNotice.defaults();

    if (!mounted) {
      return;
    }

    setState(() {
      _loaded = true;
      _now = DateTime.now();
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _now = DateTime.now();
        _tickCount += 1;
        if (_tickCount % 8 == 0) {
          _hadithIndex = (_hadithIndex + 1) % _hadiths.length;
        }
      });
    });

    _hadithTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hadithIndex = (_hadithIndex + 1) % _hadiths.length;
      });
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _hadithTimer?.cancel();
    _pulseController.dispose();
    _mosqueController.dispose();
    _noticeTitleController.dispose();
    _noticeBodyController.dispose();
    super.dispose();
  }

  Future<void> _persistMosqueName() async {
    await _prefs.setString(_mosqueNameKey, _mosqueController.text.trim());
  }

  Future<void> _persistPrayers() async {
    await _prefs.setString(
      _prayersKey,
      jsonEncode(_prayers.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> _persistNotices() async {
    await _prefs.setString(
      _noticesKey,
      jsonEncode(_notices.map((entry) => entry.toJson()).toList()),
    );
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime _prayerTimeToday(TimeOfDay time) => _combine(_now, time);

  PrayerSession get _heroPrayer {
    for (final prayer in _prayers) {
      if (_now.isBefore(_prayerTimeToday(prayer.jamatTime))) {
        return prayer;
      }
    }
    return _prayers.first;
  }

  int get _activePrayerIndex {
    for (var index = 0; index < _prayers.length; index += 1) {
      final current = _prayers[index];
      final next = _prayers[(index + 1) % _prayers.length];
      final currentSalah = _prayerTimeToday(current.salahTime);
      final nextSalah = _prayerTimeToday(next.salahTime);
      if (_now.isAfter(currentSalah) && _now.isBefore(nextSalah)) {
        return index;
      }
    }
    return 0;
  }

  Future<void> _updateMosqueName() async {
    await _persistMosqueName();
    if (!mounted) {
      return;
    }
    setState(() {
      _editMosqueName = false;
    });
  }

  Future<void> _toggleAttendance(int index) async {
    setState(() {
      _prayers[index] =
          _prayers[index].copyWith(attending: !_prayers[index].attending);
    });
    await _persistPrayers();
  }

  Future<void> _toggleMute(int index) async {
    setState(() {
      _prayers[index] = _prayers[index]
          .copyWith(alertsEnabled: !_prayers[index].alertsEnabled);
    });
    await _persistPrayers();
  }

  Future<void> _adjustPrayerTime(int index) async {
    final prayer = _prayers[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: prayer.jamatTime,
      helpText: 'Adjust Jamat time for ${prayer.label}',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _prayers[index] = prayer.copyWith(jamatTime: picked);
    });
    await _persistPrayers();
  }

  Future<void> _sendReminderChime() async {
    for (var count = 0; count < 3; count += 1) {
      await SystemSound.play(SystemSoundType.click);
      await Future<void>.delayed(const Duration(milliseconds: 220));
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          title: Text(
            'Reminder tested',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'A gentle three-note reminder played successfully for ${_heroPrayer.label}.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitNotice() async {
    final title = _noticeTitleController.text.trim();
    final body = _noticeBodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      return;
    }

    setState(() {
      _notices = [
        BulletinNotice(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          body: body,
          tag: _selectedNoticeTag,
          reactions: 0,
          isCustom: true,
        ),
        ..._notices,
      ];
      _noticeTitleController.clear();
      _noticeBodyController.clear();
      _selectedNoticeTag = _noticeTags.first;
      _noticeDrawerOpen = false;
    });

    await _persistNotices();
  }

  Future<void> _toggleReaction(String id) async {
    setState(() {
      _notices = _notices.map((notice) {
        if (notice.id != id) {
          return notice;
        }
        return notice.copyWith(reactions: notice.reactions + 1);
      }).toList();
    });
    await _persistNotices();
  }

  Future<void> _deleteNotice(String id) async {
    setState(() {
      _notices = _notices.where((notice) => notice.id != id).toList();
    });
    await _persistNotices();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  Duration _countdownTo(TimeOfDay time) {
    final target = _prayerTimeToday(time);
    var difference = target.difference(_now);
    if (difference.isNegative) {
      difference = Duration.zero;
    }
    return difference;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final heroPrayer = _heroPrayer;
    final heroPrayerIndex = _prayers.indexOf(heroPrayer);
    final activePrayerIndex = _activePrayerIndex;
    final gregorian = DateFormat('EEEE, MMMM d').format(_now);
    final hijri = HijriDate.fromGregorian(_now);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          const _LuxuryBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      _HeaderSection(
                        mosqueNameController: _mosqueController,
                        isEditing: _editMosqueName,
                        onEditPressed: () {
                          setState(() {
                            _editMosqueName = true;
                          });
                        },
                        onEditSubmit: _updateMosqueName,
                        onEditCancel: () {
                          setState(() {
                            _editMosqueName = false;
                            _mosqueController.text =
                                _prefs.getString(_mosqueNameKey) ??
                                'Al-Noor Islamic Center';
                          });
                        },
                        nowLabel: gregorian,
                        hijriLabel: hijri.label,
                        clockLabel: DateFormat('hh:mm:ss a').format(_now),
                        pulse: _pulseController,
                      ),
                      const SizedBox(height: 18),
                      _HeroPrayerCard(
                        prayer: heroPrayer,
                        prayerIndex: heroPrayerIndex,
                        jamatCountdown: _countdownTo(heroPrayer.jamatTime),
                        salahCountdown: _countdownTo(heroPrayer.salahTime),
                        isAttending: heroPrayer.attending,
                        isAlertsEnabled: heroPrayer.alertsEnabled,
                        onTestReminder: _sendReminderChime,
                      ),
                      const SizedBox(height: 18),
                      _SectionHeading(
                        title: 'Prayer timetable',
                        subtitle:
                            'Congregational timings with quick attendance and alert controls.',
                        accent: cs.secondary,
                      ),
                      const SizedBox(height: 12),
                      _PrayerTable(
                        prayers: _prayers,
                        activeIndex: activePrayerIndex,
                        onTapJamat: _adjustPrayerTime,
                        onToggleAttendance: _toggleAttendance,
                        onToggleMute: _toggleMute,
                        formatTimeOfDay: _formatTimeOfDay,
                      ),
                      const SizedBox(height: 18),
                      _SectionHeading(
                        title: 'Community bulletin',
                        subtitle:
                            'Local notices stay on the device and can be added offline.',
                        accent: cs.primary,
                      ),
                      const SizedBox(height: 12),
                      _NoticeBoard(
                        open: _noticeDrawerOpen,
                        tags: _noticeTags,
                        selectedTag: _selectedNoticeTag,
                        titleController: _noticeTitleController,
                        bodyController: _noticeBodyController,
                        onToggleOpen: () {
                          setState(() {
                            _noticeDrawerOpen = !_noticeDrawerOpen;
                          });
                        },
                        onSubmit: _submitNotice,
                        notices: _notices,
                        onTagChanged: (tag) {
                          setState(() {
                            _selectedNoticeTag = tag;
                          });
                        },
                        onReact: _toggleReaction,
                        onDelete: _deleteNotice,
                      ),
                      const SizedBox(height: 18),
                      _SectionHeading(
                        title: 'Hadith of the day',
                        subtitle: 'A rotating reflection for the evening and the morning.',
                        accent: cs.tertiary,
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.08, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _HadithBanner(
                          key: ValueKey(_hadithIndex),
                          entry: _hadiths[_hadithIndex],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryBackground extends StatelessWidget {
  const _LuxuryBackground();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _GlowOrb(
                size: 220,
                color: Color(0x0F064E3B),
              ),
            ),
            Positioned(
              top: 240,
              left: -100,
              child: _GlowOrb(
                size: 240,
                color: Color(0x09064E3B),
              ),
            ),
            Positioned(
              bottom: 120,
              right: -110,
              child: _GlowOrb(
                size: 260,
                color: Color(0x0A064E3B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.mosqueNameController,
    required this.isEditing,
    required this.onEditPressed,
    required this.onEditSubmit,
    required this.onEditCancel,
    required this.nowLabel,
    required this.hijriLabel,
    required this.clockLabel,
    required this.pulse,
  });

  final TextEditingController mosqueNameController;
  final bool isEditing;
  final VoidCallback onEditPressed;
  final Future<void> Function() onEditSubmit;
  final VoidCallback onEditCancel;
  final String nowLabel;
  final String hijriLabel;
  final String clockLabel;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isEditing)
                  Expanded(
                    child: TextField(
                      controller: mosqueNameController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => onEditSubmit(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      mosqueNameController.text,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isEditing ? onEditSubmit : onEditPressed,
                  icon: Icon(isEditing ? Icons.check_rounded : Icons.edit_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.primary.withValues(alpha: 0.12),
                    foregroundColor: cs.primary,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                if (isEditing)
                  IconButton(
                    onPressed: onEditCancel,
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      foregroundColor: cs.onSurface.withValues(alpha: 0.8),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Luxury black canvas, emerald glow, and gold scripture-inspired rhythm.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.76),
                height: 1.4,
              ),
            ),
          ],
        );

        final dateBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nowLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hijriLabel,
              textAlign: TextAlign.start,
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: pulse,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.985 + (pulse.value * 0.02),
                  child: child,
                );
              },
              child: Text(
                clockLabel,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: cs.secondary,
                  letterSpacing: 3.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _AppMark(size: 76),
                    const SizedBox(width: 16),
                    Expanded(child: titleBlock),
                    const SizedBox(width: 18),
                    dateBlock,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _AppMark(size: 68),
                        const SizedBox(width: 14),
                        Expanded(child: titleBlock),
                      ],
                    ),
                    const SizedBox(height: 18),
                    dateBlock,
                  ],
                ),
        );
      },
    );
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Icon(
        Icons.mosque_rounded,
        color: Colors.black,
        size: 34,
      ),
    );
  }
}

class _HeroPrayerCard extends StatelessWidget {
  const _HeroPrayerCard({
    required this.prayer,
    required this.prayerIndex,
    required this.jamatCountdown,
    required this.salahCountdown,
    required this.isAttending,
    required this.isAlertsEnabled,
    required this.onTestReminder,
  });

  final PrayerSession prayer;
  final int prayerIndex;
  final Duration jamatCountdown;
  final Duration salahCountdown;
  final bool isAttending;
  final bool isAlertsEnabled;
  final VoidCallback onTestReminder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = AppThemeLookup.prayerColorForIndex(prayerIndex, cs);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Next: ${prayer.label.toUpperCase()}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              if (isAttending)
                _PillBadge(
                  text: 'Attending Jamat Today',
                  color: cs.tertiary,
                  icon: Icons.verified_rounded,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            prayer.label,
            style: theme.textTheme.displaySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prayer.note,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 460;
              final jamatBox = _CountdownBox(
                title: 'Jamat',
                subtitle: 'Congregation',
                value: _formatCountdown(jamatCountdown),
                accent: cs.secondary,
                helper: prayer.jamatLabel,
              );
              final salahBox = _CountdownBox(
                title: 'Salah',
                subtitle: 'Athan start',
                value: _formatCountdown(salahCountdown),
                accent: accent,
                helper: prayer.salahLabel,
              );

              return isWide
                  ? Row(
                      children: [
                        Expanded(child: jamatBox),
                        const SizedBox(width: 12),
                        Expanded(child: salahBox),
                      ],
                    )
                  : Column(
                      children: [
                        jamatBox,
                        const SizedBox(height: 12),
                        salahBox,
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _PillBadge(
                text: isAlertsEnabled ? 'Alerts enabled' : 'Muted',
                color: isAlertsEnabled
                    ? cs.secondary
                    : Colors.white.withValues(alpha: 0.2),
                icon: isAlertsEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: onTestReminder,
                icon: const Icon(Icons.notifications_none_rounded),
                label: const Text('Test Jamat Reminder'),
                style: TextButton.styleFrom(
                  foregroundColor: cs.onSurface,
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCountdown(Duration duration) {
    if (duration == Duration.zero) {
      return '00:00:00';
    }
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

class _CountdownBox extends StatelessWidget {
  const _CountdownBox({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.helper,
  });

  final String title;
  final String subtitle;
  final String value;
  final Color accent;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontFamily: 'monospace',
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.text, required this.color, required this.icon});

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 42,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrayerTable extends StatelessWidget {
  const _PrayerTable({
    required this.prayers,
    required this.activeIndex,
    required this.onTapJamat,
    required this.onToggleAttendance,
    required this.onToggleMute,
    required this.formatTimeOfDay,
  });

  final List<PrayerSession> prayers;
  final int activeIndex;
  final Future<void> Function(int index) onTapJamat;
  final Future<void> Function(int index) onToggleAttendance;
  final Future<void> Function(int index) onToggleMute;
  final String Function(TimeOfDay time) formatTimeOfDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                const Expanded(flex: 3, child: _TableHeader('Prayer')),
                const Expanded(flex: 2, child: _TableHeader('Salah')),
                const Expanded(flex: 2, child: _TableHeader('Jamat')),
                const Expanded(flex: 1, child: _TableHeader('Attend')),
                const Expanded(flex: 1, child: _TableHeader('Alert')),
              ],
            ),
          ),
          for (var index = 0; index < prayers.length; index += 1)
            _PrayerRow(
              prayer: prayers[index],
              active: index == activeIndex,
              accent: AppThemeLookup.prayerColorForIndex(index, cs),
              onTapJamat: () => onTapJamat(index),
              onToggleAttendance: () => onToggleAttendance(index),
              onToggleMute: () => onToggleMute(index),
              formatTimeOfDay: formatTimeOfDay,
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.prayer,
    required this.active,
    required this.accent,
    required this.onTapJamat,
    required this.onToggleAttendance,
    required this.onToggleMute,
    required this.formatTimeOfDay,
  });

  final PrayerSession prayer;
  final bool active;
  final Color accent;
  final VoidCallback onTapJamat;
  final VoidCallback onToggleAttendance;
  final VoidCallback onToggleMute;
  final String Function(TimeOfDay time) formatTimeOfDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: active
            ? accent.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: active ? accent : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prayer.offsetLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatTimeOfDay(prayer.salahTime),
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: onTapJamat,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTimeOfDay(prayer.jamatTime),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accent,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tap to edit',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: InkResponse(
                onTap: onToggleAttendance,
                radius: 22,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: prayer.attending ? accent : Colors.transparent,
                    border: Border.all(
                      color: prayer.attending
                          ? accent
                          : cs.onSurface.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: prayer.attending ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                onPressed: onToggleMute,
                icon: Icon(
                  prayer.alertsEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                ),
                color: prayer.alertsEnabled
                    ? cs.secondary
                    : cs.onSurface.withValues(alpha: 0.4),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.03),
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeBoard extends StatelessWidget {
  const _NoticeBoard({
    required this.open,
    required this.tags,
    required this.selectedTag,
    required this.titleController,
    required this.bodyController,
    required this.onToggleOpen,
    required this.onSubmit,
    required this.notices,
    required this.onTagChanged,
    required this.onReact,
    required this.onDelete,
  });

  final bool open;
  final List<String> tags;
  final String selectedTag;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final VoidCallback onToggleOpen;
  final Future<void> Function() onSubmit;
  final List<BulletinNotice> notices;
  final ValueChanged<String> onTagChanged;
  final Future<void> Function(String id) onReact;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleOpen,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Icon(Icons.post_add_rounded, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      open ? 'Close notice composer' : 'Add a community notice',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: cs.onSurface),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 12),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Notice title',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Detail description',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedTag,
                          items: tags
                              .map(
                                (tag) => DropdownMenuItem<String>(
                                  value: tag,
                                  child: Text(tag),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onTagChanged(value);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Category tag',
                            prefixIcon: Icon(Icons.label_important_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: onSubmit,
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Publish'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState:
                open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
          const SizedBox(height: 12),
          ...notices.map(
            (notice) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NoticeCard(
                notice: notice,
                onReact: () => onReact(notice.id),
                onDelete: notice.isCustom ? () => onDelete(notice.id) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notice,
    required this.onReact,
    required this.onDelete,
  });

  final BulletinNotice notice;
  final VoidCallback onReact;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notice.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (notice.isCustom)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: cs.error,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notice.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.72),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _PillBadge(
                text: notice.tag,
                color: cs.secondary,
                icon: Icons.sell_rounded,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onReact,
                icon: const Icon(Icons.favorite_rounded, size: 18),
                label: Text('JazakAllah ${notice.reactions}'),
                style: TextButton.styleFrom(
                  foregroundColor: cs.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HadithBanner extends StatelessWidget {
  const _HadithBanner({super.key, required this.entry});

  final HadithEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              entry.arabic,
              textAlign: TextAlign.right,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.primary,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            entry.english,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.86),
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            entry.source,
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.tertiary,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class AppThemeLookup {
  static Color prayerColorForIndex(int index, ColorScheme scheme) {
    final colors = [
      const Color(0xFF90CAF9),
      scheme.primary,
      const Color(0xFFD97706),
      const Color(0xFFDC8B5B),
      const Color(0xFF5EEAD4),
    ];
    return colors[index % colors.length];
  }
}

class PrayerSession {
  PrayerSession({
    required this.label,
    required this.salahTime,
    required this.offsetMinutes,
    required this.attending,
    required this.alertsEnabled,
  });

  final String label;
  final TimeOfDay salahTime;
  final int offsetMinutes;
  final bool attending;
  final bool alertsEnabled;

  String get note => '$label congregational rhythm';

  String get offsetLabel {
    final sign = offsetMinutes >= 0 ? '+' : '-';
    return '$sign${offsetMinutes.abs()} min from athan';
  }

  TimeOfDay get jamatTime {
    final totalMinutes =
        salahTime.hour * 60 + salahTime.minute + offsetMinutes;
    final normalized = (totalMinutes + 24 * 60) % (24 * 60);
    return TimeOfDay(
      hour: normalized ~/ 60,
      minute: normalized % 60,
    );
  }

  String get jamatLabel => 'Jamat ${_timeLabel(jamatTime)}';

  String get salahLabel => 'Salah ${_timeLabel(salahTime)}';

  PrayerSession copyWith({
    String? label,
    TimeOfDay? salahTime,
    int? offsetMinutes,
    bool? attending,
    bool? alertsEnabled,
    TimeOfDay? jamatTime,
  }) {
    final effectiveSalah = salahTime ?? this.salahTime;
    final effectiveOffset = jamatTime != null
        ? ((jamatTime.hour * 60 + jamatTime.minute) -
            (effectiveSalah.hour * 60 + effectiveSalah.minute))
        : offsetMinutes ?? this.offsetMinutes;
    return PrayerSession(
      label: label ?? this.label,
      salahTime: effectiveSalah,
      offsetMinutes: effectiveOffset,
      attending: attending ?? this.attending,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'salahHour': salahTime.hour,
        'salahMinute': salahTime.minute,
        'offsetMinutes': offsetMinutes,
        'attending': attending,
        'alertsEnabled': alertsEnabled,
      };

  static List<PrayerSession>? fromJsonList(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(payload) as List<dynamic>;
    return decoded
        .map(
          (item) => PrayerSession(
            label: item['label'] as String,
            salahTime: TimeOfDay(
              hour: item['salahHour'] as int,
              minute: item['salahMinute'] as int,
            ),
            offsetMinutes: item['offsetMinutes'] as int,
            attending: item['attending'] as bool,
            alertsEnabled: item['alertsEnabled'] as bool,
          ),
        )
        .toList();
  }

  static List<PrayerSession> defaults() {
    return [
      PrayerSession(
        label: 'Fajr',
        salahTime: const TimeOfDay(hour: 5, minute: 10),
        offsetMinutes: 15,
        attending: true,
        alertsEnabled: true,
      ),
      PrayerSession(
        label: 'Dhuhr',
        salahTime: const TimeOfDay(hour: 13, minute: 5),
        offsetMinutes: 15,
        attending: false,
        alertsEnabled: true,
      ),
      PrayerSession(
        label: 'Asr',
        salahTime: const TimeOfDay(hour: 16, minute: 30),
        offsetMinutes: 15,
        attending: true,
        alertsEnabled: true,
      ),
      PrayerSession(
        label: 'Maghrib',
        salahTime: const TimeOfDay(hour: 18, minute: 12),
        offsetMinutes: 10,
        attending: false,
        alertsEnabled: true,
      ),
      PrayerSession(
        label: 'Isha',
        salahTime: const TimeOfDay(hour: 20, minute: 0),
        offsetMinutes: 15,
        attending: true,
        alertsEnabled: true,
      ),
    ];
  }
}

class BulletinNotice {
  BulletinNotice({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
    required this.reactions,
    required this.isCustom,
  });

  final String id;
  final String title;
  final String body;
  final String tag;
  final int reactions;
  final bool isCustom;

  BulletinNotice copyWith({int? reactions}) {
    return BulletinNotice(
      id: id,
      title: title,
      body: body,
      tag: tag,
      reactions: reactions ?? this.reactions,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'tag': tag,
        'reactions': reactions,
        'isCustom': isCustom,
      };

  static List<BulletinNotice>? fromJsonList(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(payload) as List<dynamic>;
    return decoded
        .map(
          (item) => BulletinNotice(
            id: item['id'] as String,
            title: item['title'] as String,
            body: item['body'] as String,
            tag: item['tag'] as String,
            reactions: item['reactions'] as int,
            isCustom: item['isCustom'] as bool,
          ),
        )
        .toList();
  }

  static List<BulletinNotice> defaults() {
    return [
      BulletinNotice(
        id: 'jummah',
        title: 'Friday Jummah Times',
        body:
            'The second khutbah starts promptly at 1:45 PM. Please arrive early for the front rows and quiet reflection.',
        tag: 'Announcement',
        reactions: 24,
        isCustom: false,
      ),
      BulletinNotice(
        id: 'tafseer',
        title: 'Daily Tafsir Study Circle',
        body:
            'Tonight after Isha: a short tafsir circle with tea in the community hall. Families and youth are welcome.',
        tag: 'Circle',
        reactions: 11,
        isCustom: false,
      ),
      BulletinNotice(
        id: 'zakat',
        title: 'Zakat Donation Drive',
        body:
            'Contribute online or at the desk before Maghrib. Every contribution supports food parcels and local aid.',
        tag: 'Donation',
        reactions: 18,
        isCustom: false,
      ),
    ];
  }
}

class HadithEntry {
  const HadithEntry({
    required this.arabic,
    required this.english,
    required this.source,
  });

  final String arabic;
  final String english;
  final String source;
}

class HijriDate {
  HijriDate({required this.day, required this.month, required this.year});

  final int day;
  final String month;
  final int year;

  String get label => '$day $month $year AH';

  static HijriDate fromGregorian(DateTime date) {
    final julianDay =
        _julianDayFromGregorian(DateTime.utc(date.year, date.month, date.day));
    var l = julianDay - 1948440 + 10632;
    final n = l ~/ 10631;
    l = l - 10631 * n + 354;

    final j = ((((10985 - l) / 5316).floor()) *
            (((50 * l) / 17719).floor())) +
        (((l / 5670).floor()) * (((43 * l) / 15238).floor()));

    l = l - ((((30 - j) / 15).floor()) * (((17719 * j) / 50).floor())) -
        (((j / 16).floor()) * (((15238 * j) / 43).floor())) +
        29;

    final month = ((24 * l) / 709).floor();
    final day = l - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;

    const months = <String>[
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Shaban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qadah',
      'Dhu al-Hijjah',
    ];

    return HijriDate(
      day: day,
      month: months[month.clamp(1, months.length) - 1],
      year: year,
    );
  }

  static int _julianDayFromGregorian(DateTime date) {
    final a = (14 - date.month) ~/ 12;
    final y = date.year + 4800 - a;
    final m = date.month + 12 * a - 3;
    return date.day + ((153 * m + 2) ~/ 5) + 365 * y + (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;
  }
}

String _timeLabel(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}