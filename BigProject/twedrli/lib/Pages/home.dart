import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twedrli/Lists/list.dart'; // ← model now lives here

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
      darkTheme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
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

  Widget _buildDetailImage(LostFoundItem item, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget imageWidget;
    if (item.imagePath.isEmpty) {
      imageWidget = Container(
        color: isDark ? Colors.grey[800] : const Color(0xFFE3F2FD),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      );
    } else if (item.imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(
        item.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.broken_image,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      );
    } else {
      imageWidget = Image.file(
        File(item.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.broken_image,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            toolbarHeight: 120,
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
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
                  color: isDark ? Colors.grey[800] : const Color(0xFFE3F2FD),
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 16,
                      color: isDark
                          ? Colors.grey[600]
                          : const Color(0xFFBBDEFB),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$claimedCount claimed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.grey[500]
                            : const Color(0xFF757575),
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
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                                        : (isDark
                                              ? Colors.grey[400]
                                              : const Color(0xFF555555)),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) =>
                                    setState(() => _selectedFilterIndex = i),
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.white,
                                selectedColor: theme.colorScheme.primary,
                                checkmarkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.transparent
                                        : (isDark
                                              ? Colors.grey[700]!
                                              : const Color(0xFFE0E0E0)),
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
                      onTap: () => setState(
                        () => _isSortMenuVisible = !_isSortMenuVisible,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[800]!
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _currentSort.icon,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Sort',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Icon(
                              _isSortMenuVisible
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                              color: theme.colorScheme.primary,
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
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      Divider(
                        height: 1,
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: SortOption.values.map((option) {
                          final isSelected = option == _currentSort;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _currentSort = option;
                                _isSortMenuVisible = false;
                              }),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                            ? theme.colorScheme.primary
                                                  .withOpacity(0.2)
                                            : const Color(0xFFE3F2FD))
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      option.icon,
                                      size: 18,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : (isDark
                                                ? Colors.grey[500]
                                                : const Color(0xFF757575)),
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
                                            ? theme.colorScheme.primary
                                            : (isDark
                                                  ? Colors.grey[500]
                                                  : const Color(0xFF757575)),
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
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[500],
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
                              childAspectRatio: 0.58,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: _buildDetailImage(item, context),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[500]
                                : const Color(0xFF999999),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.location,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description.isNotEmpty
                          ? item.description
                          : 'No description provided',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[800]!
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.contactInfo.isNotEmpty
                                  ? item.contactInfo
                                  : 'No contact information provided',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[300]
                                    : const Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (item.status != ItemStatus.claimed) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
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
                                color: isDark
                                    ? Colors.grey[700]!
                                    : const Color(0xFFE0E0E0),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share),
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF555555),
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
}

// ─────────────────────────────────────────────
// ITEM IMAGE WIDGET
// ─────────────────────────────────────────────

class _ItemImage extends StatelessWidget {
  final String imagePath;
  final bool isClaimed;

  const _ItemImage({required this.imagePath, required this.isClaimed});

  Widget _buildImage(BoxFit fit, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imagePath.isEmpty) {
      return Container(
        color: isDark ? Colors.grey[800] : const Color(0xFFE3F2FD),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
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
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: fit,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.broken_image,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: ColoredBox(
        color: isDark ? Colors.grey[900]! : Colors.grey.shade200,
        child: isClaimed
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(BoxFit.cover, context),
                  Container(color: Colors.black.withOpacity(0.5)),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 24,
                            color: Color(0xFF43A047),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Returned to Owner',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : _buildImage(BoxFit.cover, context),
      ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
                        Icon(_getStatusIcon(), size: 10, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          _badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]!.withOpacity(0.9)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.transparent
                              : Colors.black.withOpacity(0.1),
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
                          size: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.item.timeAgo,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!_isClaimed)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800]! : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.transparent
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          size: 16,
                          color: _isSaved
                              ? theme.colorScheme.primary
                              : (isDark
                                    ? Colors.grey[400]
                                    : const Color(0xFF555555)),
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
                              backgroundColor: isDark ? Colors.grey[900] : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _isClaimed
                                  ? (isDark
                                        ? Colors.grey[600]
                                        : const Color(0xFF999999))
                                  : (isDark
                                        ? Colors.white
                                        : const Color(0xFF111111)),
                              decoration: _isClaimed
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: isDark
                                  ? Colors.grey[600]
                                  : const Color(0xFF999999),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!_isClaimed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#${widget.item.id}',
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark
                                    ? Colors.grey[500]
                                    : const Color(0xFF999999),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: isDark
                              ? Colors.grey[500]
                              : const Color(0xFF757575),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            widget.item.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[500]
                                  : const Color(0xFF757575),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (widget.item.description.isNotEmpty && !_isClaimed) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 13,
                            color: isDark
                                ? Colors.grey[500]
                                : const Color(0xFF757575),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              widget.item.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[500]
                                    : const Color(0xFF888888),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Spacer(),
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
                                    backgroundColor: isDark
                                        ? Colors.grey[900]
                                        : null,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                widget.item.status == ItemStatus.lost
                                    ? 'Contact'
                                    : 'Claim',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[700]!
                                    : const Color(0xFFE0E0E0),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share_outlined, size: 16),
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF555555),
                              padding: EdgeInsets.zero,
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
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.onTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF757575),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
