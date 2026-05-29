import 'package:flutter/material.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:jamat_timings/data/models/masjid.dart';
import 'package:jamat_timings/widgets/masjid_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Masjid> _searchResults = [];
  String _activeFilter = 'All'; // All, Name, Area, City

  @override
  void initState() {
    super.initState();
    _searchResults = MockData.masjids;
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = MockData.masjids;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _searchResults = MockData.masjids.where((masjid) {
        final matchesName = masjid.name.toLowerCase().contains(lowercaseQuery);
        final matchesArea = masjid.area?.toLowerCase().contains(lowercaseQuery) ?? false;
        final matchesCity = masjid.city.toLowerCase().contains(lowercaseQuery);

        if (_activeFilter == 'Name') return matchesName;
        if (_activeFilter == 'Area') return matchesArea;
        if (_activeFilter == 'City') return matchesCity;

        return matchesName || matchesArea || matchesCity;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Masjids', style: theme.textTheme.titleLarge),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by masjid name, area, or city...',
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.35)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Filter Chips Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Name', 'Area', 'City'].map((filter) {
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _activeFilter = filter;
                      });
                      _onSearchChanged(_searchController.text);
                    },
                    selectedColor: colorScheme.primary.withValues(alpha: 0.18),
                    checkmarkColor: colorScheme.primary,
                    backgroundColor: colorScheme.surface,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Search Results List
          Expanded(
            child: _searchResults.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final masjid = _searchResults[index];
                      return MasjidCard(
                        masjid: masjid,
                        isFavourite: masjid.id == 'm1',
                        onFavouriteToggle: () {},
                        nextPrayerName: masjid.id == 'm1' ? 'isha' : 'maghrib',
                        nextPrayerTime: masjid.id == 'm1' ? '20:45' : '19:15',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No masjids found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try typing a different name or neighborhood.',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
