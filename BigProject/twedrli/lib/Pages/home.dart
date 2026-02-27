import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twedrli/Lists/list.dart';

void main() {
  runApp(const TwedrliApp());
}

class TwedrliApp extends StatelessWidget {
  const TwedrliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

enum ItemStatus { lost, found, claimed }

enum SortOption { newest, oldest, alphabetAZ, alphabetZA }

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.alphabetAZ:
        return 'A to Z';
      case SortOption.alphabetZA:
        return 'Z to A';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.newest:
        return Icons.arrow_downward;
      case SortOption.oldest:
        return Icons.arrow_upward;
      case SortOption.alphabetAZ:
        return Icons.sort_by_alpha;
      case SortOption.alphabetZA:
        return Icons.sort_by_alpha;
    }
  }
}

class LostFoundItem {
  final String id;
  final String title;
  final String location;
  final DateTime timestamp;
  final ItemStatus status;
  final String imagePath;
  final String description;
  final String contactInfo;
  final String color;
  final String category;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  const LostFoundItem({
    required this.id,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.status,
    required this.imagePath,
    this.description = '',
    this.contactInfo = '',
    this.color = '',
    required this.category,
  });
}

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilterIndex = 0;
  SortOption _currentSort = SortOption.newest;
  bool _isSortMenuVisible = false;

  static const List<String> _filterLabels = ['All', 'Lost', 'Found', 'Claimed'];

  List<LostFoundItem> _getFilteredItems(List<LostFoundItem> items) {
    Iterable<LostFoundItem> filtered = items;

    if (_selectedFilterIndex != 0) {
      final status = ItemStatus.values[_selectedFilterIndex - 1];
      filtered = filtered.where((item) => item.status == status);
    }

    return filtered.toList()..sort((a, b) {
      switch (_currentSort) {
        case SortOption.newest:
          return b.timestamp.compareTo(a.timestamp);
        case SortOption.oldest:
          return a.timestamp.compareTo(b.timestamp);
        case SortOption.alphabetAZ:
          return a.title.compareTo(b.title);
        case SortOption.alphabetZA:
          return b.title.compareTo(a.title);
      }
    });
  }

  // ── Builds the correct image widget for both asset and file paths ──
  Widget _buildDetailImage(LostFoundItem item) {
    Widget imageWidget;

    if (item.imagePath.isEmpty) {
      imageWidget = Container(
        color: const Color(0xFFE3F2FD),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 60,
            color: Colors.grey[400],
          ),
        ),
      );
    } else if (item.imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(
        item.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
        ),
      );
    } else {
      imageWidget = Image.file(
        File(item.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
        ),
      );
    }

    if (item.status == ItemStatus.claimed) {
      return Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Color(0xFF43A047),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Returned to Owner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return imageWidget;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<LostFoundItem>>(
      valueListenable: allItemsNotifier,
      builder: (context, items, _) {
        final filteredItems = _getFilteredItems(items);
        final activeCount = items
            .where((i) => i.status != ItemStatus.claimed)
            .length;
        final claimedCount = items
            .where((i) => i.status == ItemStatus.claimed)
            .length;

        return Scaffold(
          backgroundColor: const Color.fromARGB(0, 248, 249, 250),
          appBar: AppBar(
            toolbarHeight: 120,
            leading: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset('assets/logo.png', height: 70, width: 50),
            ),
            leadingWidth: 100,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$activeCount active',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 16,
                      color: const Color(0xFFBBDEFB),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$claimedCount claimed',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Filter and Sort Bar ──
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_filterLabels.length, (i) {
                            final bool isSelected = i == _selectedFilterIndex;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  _filterLabels[i],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF555555),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => _selectedFilterIndex = i);
                                },
                                backgroundColor: Colors.white,
                                selectedColor: const Color(0xFF2196F3),
                                checkmarkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.transparent
                                        : const Color(0xFFE0E0E0),
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(
                          () => _isSortMenuVisible = !_isSortMenuVisible,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _currentSort.icon,
                              size: 18,
                              color: const Color(0xFF2196F3),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Sort',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            Icon(
                              _isSortMenuVisible
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                              color: const Color(0xFF2196F3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sort Options Menu ──
              if (_isSortMenuVisible)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: SortOption.values.map((option) {
                          final isSelected = option == _currentSort;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentSort = option;
                                  _isSortMenuVisible = false;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFE3F2FD)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      option.icon,
                                      size: 18,
                                      color: isSelected
                                          ? const Color(0xFF2196F3)
                                          : const Color(0xFF757575),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      option.label.split(' ').first,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFF2196F3)
                                            : const Color(0xFF757575),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              // ── Items List ──
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return _ItemCard(
                            item: filteredItems[index],
                            onTap: () =>
                                _showItemDetails(context, filteredItems[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showItemDetails(BuildContext context, LostFoundItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Item image (fixed) ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: _buildDetailImage(item), // ← THE FIX
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status and time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              item.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status.name.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(item.status),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.timeAgo,
                          style: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.location,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description.isNotEmpty
                          ? item.description
                          : 'No description provided',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contact Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF2196F3),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.contactInfo,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action buttons
                    if (item.status != ItemStatus.claimed) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                item.status == ItemStatus.lost
                                    ? 'Contact Owner'
                                    : 'Claim Item',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share),
                              color: const Color(0xFF555555),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return const Color(0xFFE53935);
      case ItemStatus.found:
        return const Color(0xFF1E88E5);
      case ItemStatus.claimed:
        return const Color(0xFF43A047);
    }
  }

  IconData _getIconForPath(String path) {
    if (path.contains('Bottle')) return Icons.local_drink;
    if (path.contains('calc')) return Icons.calculate;
    if (path.contains('keys')) return Icons.vpn_key;
    if (path.contains('charger')) return Icons.battery_charging_full;
    if (path.contains('headphones')) return Icons.headphones;
    return Icons.image;
  }

  String _getFileName(String path) {
    final uri = Uri.file(path);
    return uri.pathSegments.last.replaceAll('.png', '').replaceAll('.jpg', '');
  }
} // ← _HomeScreenState ends here

// ─────────────────────────────────────────────
// ITEM IMAGE WIDGET
// ─────────────────────────────────────────────
class _ItemImage extends StatelessWidget {
  final String imagePath;
  final bool isClaimed;

  const _ItemImage({required this.imagePath, required this.isClaimed});

  Widget _buildImage(BoxFit fit) {
    if (imagePath.isEmpty) {
      return Container(
        color: const Color(0xFFE3F2FD),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            _getIconForPath(imagePath),
            size: 48,
            color: Colors.grey[400],
          ),
        ),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: fit,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // This controls the height of the image container
      width: double.infinity,
      color: Colors.grey[200],
      child: isClaimed
          ? Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(BoxFit.cover),
                Container(color: Colors.black.withOpacity(0.5)),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8), // Reduced from 12
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 24, // Reduced from 32
                          color: Color(0xFF43A047),
                        ),
                      ),
                      const SizedBox(height: 4), // Reduced from 8
                      const Text(
                        'Returned to Owner',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11, // Reduced from 14
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : _buildImage(BoxFit.cover),
    );
  }

  IconData _getIconForPath(String path) {
    if (path.contains('Bottle')) return Icons.local_drink;
    if (path.contains('calc')) return Icons.calculate;
    if (path.contains('keys')) return Icons.vpn_key;
    if (path.contains('charger')) return Icons.battery_charging_full;
    if (path.contains('headphones')) return Icons.headphones;
    return Icons.image;
  }
}
// ─────────────────────────────────────────────
// ITEM CARD
// ─────────────────────────────────────────────

class _ItemCard extends StatefulWidget {
  final LostFoundItem item;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = savedItemsNotifier.value.any((s) => s.id == widget.item.id);
  }

  Color get _badgeColor {
    switch (widget.item.status) {
      case ItemStatus.lost:
        return const Color(0xFFE53935);
      case ItemStatus.found:
        return const Color(0xFF1E88E5);
      case ItemStatus.claimed:
        return const Color(0xFF43A047);
    }
  }

  String get _badgeText => widget.item.status.name.toUpperCase();
  bool get _isClaimed => widget.item.status == ItemStatus.claimed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: _ItemImage(
                    imagePath: widget.item.imagePath,
                    isClaimed: _isClaimed,
                  ),
                ),

                // Status Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _badgeColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _badgeColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(), size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          _badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Time indicator
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Save button
                if (!_isClaimed)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          size: 18,
                          color: _isSaved
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF555555),
                        ),
                        onPressed: () {
                          final saved = savedItemsNotifier.value;
                          final alreadySaved = saved.any(
                            (s) => s.id == widget.item.id,
                          );

                          if (alreadySaved) {
                            savedItemsNotifier.value = saved
                                .where((s) => s.id != widget.item.id)
                                .toList();
                          } else {
                            savedItemsNotifier.value = [...saved, widget.item];
                          }

                          setState(() => _isSaved = !alreadySaved);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                !alreadySaved
                                    ? '${widget.item.title} saved'
                                    : '${widget.item.title} removed from saved',
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _isClaimed
                                ? const Color(0xFF999999)
                                : const Color(0xFF111111),
                            decoration: _isClaimed
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: const Color(0xFF999999),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!_isClaimed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${widget.item.id}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF999999),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF757575),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.item.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (widget.item.description.isNotEmpty && !_isClaimed) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.item.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF888888),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  if (!_isClaimed) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.item.status == ItemStatus.lost
                                        ? 'Contacting owner...'
                                        : 'Claiming item...',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              widget.item.status == ItemStatus.lost
                                  ? 'Contact Owner'
                                  : 'Claim Item',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share_outlined, size: 20),
                            color: const Color(0xFF555555),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sharing item...'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF757575),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (widget.item.status) {
      case ItemStatus.lost:
        return Icons.error_outline;
      case ItemStatus.found:
        return Icons.check_circle_outline;
      case ItemStatus.claimed:
        return Icons.verified;
    }
  }
}
