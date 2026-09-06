import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/Activity/chat.dart';

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
  late PageController _carouselController;
  Timer? _carouselTimer;
  int _carouselIndex = 0;

  static const List<String> _filterLabels = ['All', 'Lost', 'Found', 'Claimed'];

  void initState() {
    super.initState();
    _carouselController = PageController(initialPage: 0);
    _startCarousel();
    TwedrliApi.fetchProducts();
  }

  void _startCarousel() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselController.hasClients) {
        final featuredCount = allItemsNotifier.value
            .where((i) => i.status == ItemStatus.found)
            .take(5)
            .length;
        if (featuredCount > 1) {
          _carouselIndex = (_carouselIndex + 1) % featuredCount;
          _carouselController.animateToPage(
            _carouselIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  // ── UI HELPERS ─────────────────────────────────────────────────────────────

  Widget _buildCarousel(bool isDark, List<LostFoundItem> items) {
    // Feature up to 5 recent found items
    final featured = items
        .where((i) => i.status == ItemStatus.found)
        .take(5)
        .toList();

    if (featured.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: PageView.builder(
        controller: _carouselController,
        itemCount: featured.length,
        onPageChanged: (i) => _carouselIndex = i,
        itemBuilder: (context, index) {
          final item = featured[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: _getImageProvider(item),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFAE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FEATURED FOUND',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Found at ${item.location}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
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

  ImageProvider _getImageProvider(LostFoundItem item) {
    if (item.imagePath.startsWith('http')) {
      return NetworkImage(item.imagePath);
    } else if (item.imagePath.startsWith('data:image')) {
       final bytes = base64Decode(item.imagePath.split(',').last);
       return MemoryImage(bytes);
    } else if (item.imagePath.startsWith('assets/')) {
      return AssetImage(item.imagePath);
    } else if (item.imagePath.isNotEmpty) {
      return FileImage(File(item.imagePath));
    }
    return const AssetImage('assets/logo.png'); // Fallback
  }

  Widget _buildHeroStats(bool isDark, int activeCount, int claimedCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campus Status',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Helping students\nfind lost items.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _statItem('Active', activeCount.toString(), Icons.search_rounded),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _statItem('Recovered', claimedCount.toString(), Icons.verified_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, {double margin = 16}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: margin),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, bool isDark) {
    final isActive = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1E88E5)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          ),
        ),
        child: Center(
          child: Text(
            _filterLabels[index],
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : const Color(0xFFBBDEFB),
        ),
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
          const SizedBox(width: 8),
          Text(
            '$count Active',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _isSortMenuVisible = !_isSortMenuVisible),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sort_rounded,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                'Sort',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters or search query.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

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
        color: isDark ? Colors.grey[800] : _colorForCategory(item.category),
        child: Center(
          child: Icon(
            _iconForCategory(item.category),
            size: 60,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    } else if (item.imagePath.startsWith('http://') ||
        item.imagePath.startsWith('https://')) {
      imageWidget = Image.network(
        item.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            _iconForCategory(item.category),
            size: 60,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    } else if (item.imagePath.startsWith('data:image') ||
        _isBase64(item.imagePath)) {
      try {
        final bytes = base64Decode(
          item.imagePath.contains(',')
              ? item.imagePath.split(',').last
              : item.imagePath,
        );
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              _iconForCategory(item.category),
              size: 60,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        );
      } catch (_) {
        imageWidget = Center(
          child: Icon(
            _iconForCategory(item.category),
            size: 60,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        );
      }
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

  // ── Delete confirmation + API call ──────────────────────────────────────────
  Future<void> _deleteItem(BuildContext context, LostFoundItem item) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Post',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await TwedrliApi.deleteProduct(item.id);
      if (context.mounted) {
        if (success) {
          // Remove from local notifier immediately
          allItemsNotifier.value = allItemsNotifier.value
              .where((i) => i.id != item.id)
              .toList();
          // Also remove from saved items if saved
          savedItemsNotifier.value = savedItemsNotifier.value
              .where((i) => i.id != item.id)
              .toList();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: Color(0xFF43A047),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete post. Please try again.'),
              backgroundColor: Color(0xFFE53935),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingNotifier,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return ValueListenableBuilder<String>(
          valueListenable: errorNotifier,
          builder: (context, error, _) {
            if (error.isNotEmpty) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: TwedrliApi.fetchProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
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
                      child: Image.asset(
                        'assets/logo.png',
                        height: 70,
                        width: 50,
                      ),
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
                          color: isDark
                              ? Colors.grey[800]
                              : const Color(0xFFE3F2FD),
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
                      _buildCarousel(isDark, items),
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
                                  children: List.generate(
                                    _filterLabels.length,
                                    (i) {
                                      final bool isSelected =
                                          i == _selectedFilterIndex;

                                      // Color config per filter
                                      final List<Color> bgColors = [
                                        Colors.transparent,
                                        const Color(0xFFFFEBEE),
                                        const Color(0xFFE3F2FD),
                                        const Color(0xFFE8F5E9),
                                      ];
                                      final List<Color> borderColors = [
                                        isDark
                                            ? Colors.grey[600]!
                                            : const Color(0xFFBDBDBD),
                                        const Color(0xFFEF9A9A),
                                        const Color(0xFF90CAF9),
                                        const Color(0xFFA5D6A7),
                                      ];
                                      final List<Color> textColors = [
                                        isDark
                                            ? Colors.grey[300]!
                                            : const Color(0xFF424242),
                                        const Color(0xFFC62828),
                                        const Color(0xFF1565C0),
                                        const Color(0xFF2E7D32),
                                      ];
                                      final List<Color> dotColors = [
                                        Colors.grey,
                                        const Color(0xFFE53935),
                                        const Color(0xFF1E88E5),
                                        const Color(0xFF43A047),
                                      ];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: GestureDetector(
                                          onTap: () => setState(
                                            () => _selectedFilterIndex = i,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? (i == 0
                                                        ? theme
                                                              .colorScheme
                                                              .primary
                                                        : bgColors[i])
                                                  : (isDark
                                                        ? Colors.grey[850]
                                                        : Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              border: Border.all(
                                                color: isSelected
                                                    ? (i == 0
                                                          ? theme
                                                                .colorScheme
                                                                .primary
                                                          : borderColors[i])
                                                    : (isDark
                                                          ? Colors.grey[700]!
                                                          : const Color(
                                                              0xFFE0E0E0,
                                                            )),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: isSelected && i == 0
                                                        ? Colors.white
                                                              .withOpacity(0.85)
                                                        : dotColors[i],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 7),
                                                Text(
                                                  _filterLabels[i],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: isSelected
                                                        ? (i == 0
                                                              ? Colors.white
                                                              : textColors[i])
                                                        : (isDark
                                                              ? Colors.grey[400]
                                                              : const Color(
                                                                  0xFF616161,
                                                                )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]!
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey[600]!
                                        : const Color(0xFFBDBDBD),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _currentSort.icon,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 5),
                                  
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
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Column(
                            children: [
                              Divider(
                                height: 1,
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                                        : const Color(
                                                            0xFF757575,
                                                          )),
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
                                                          : const Color(
                                                              0xFF757575,
                                                            )),
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
: RefreshIndicator(
    onRefresh: () => TwedrliApi.fetchProducts(),
    child: GridView.builder(
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
                                  final item = filteredItems[index];
                                  // ── Check ownership ──
                                  final isOwner =
                                      item.userId != null &&
                                      item.userId ==
                                          loggedInUserIdNotifier.value;
                                  return _ItemCard(
                                    item: item,
                                    isOwner: isOwner,
                                    onTap: () =>
                                        _showItemDetails(context, item),
                                    onDelete: isOwner
                                        ? () => _deleteItem(context, item)
                                        : null,
                                  );
                                },
                              ),
                      ),)
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showItemDetails(BuildContext context, LostFoundItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final isOwner =
        item.userId != null && item.userId == loggedInUserIdNotifier.value;

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
                        // ── Show delete icon in detail if owner ──
                        if (isOwner)
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _deleteItem(context, item);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                    
              
                            ),
                          ),
                        const SizedBox(width: 8),
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
                          item.locationDisplay,
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
                          // ── Hide Contact/Claim button for own posts ──
                          if (!isOwner)
                            Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (isGuestNotifier.value) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please sign in to contact users.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    if (item.userId != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatPage(
                                            targetUserId: item.userId,
                                            relatedItemId: item.id,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Reporter ID not found'),
                                        ),
                                      );
                                    }
                                  },
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
                          if (!isOwner) const SizedBox(width: 12),
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
                              onPressed: () {
                                if (isGuestNotifier.value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please sign in to share items.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                // Implement share logic
                              },
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
// CATEGORY HELPERS
// ─────────────────────────────────────────────

bool _isBase64(String s) {
  if (s.length % 4 != 0) return false;
  return RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(s);
}

IconData _iconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'electronics':
      return Icons.devices;
    case 'fashion':
      return Icons.checkroom;
    case 'home & living':
      return Icons.chair;
    case 'beauty':
      return Icons.face;
    case 'sport':
      return Icons.sports_soccer;
    case 'books':
      return Icons.menu_book;
    default:
      return Icons.category;
  }
}

Color _colorForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'electronics':
      return const Color(0xFFE3F2FD);
    case 'fashion':
      return const Color(0xFFFCE4EC);
    case 'home & living':
      return const Color(0xFFF3E5F5);
    case 'beauty':
      return const Color(0xFFFFF8E1);
    case 'sport':
      return const Color(0xFFE8F5E9);
    case 'books':
      return const Color(0xFFFFF3E0);
    default:
      return const Color(0xFFF5F5F5);
  }
}

// ─────────────────────────────────────────────
// ITEM IMAGE WIDGET
// ─────────────────────────────────────────────

class _ItemImage extends StatelessWidget {
  final String imagePath;
  final bool isClaimed;
  final String category;

  const _ItemImage({
    required this.imagePath,
    required this.isClaimed,
    required this.category,
  });

  Widget _buildImage(BoxFit fit, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imagePath.isEmpty) {
      return Container(
        color: isDark ? Colors.grey[800] : _colorForCategory(category),
        child: Center(
          child: Icon(
            _iconForCategory(category),
            size: 48,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            _iconForCategory(category),
            size: 48,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (imagePath.startsWith('data:image') || _isBase64(imagePath)) {
      try {
        final bytes = base64Decode(
          imagePath.contains(',') ? imagePath.split(',').last : imagePath,
        );
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              _iconForCategory(category),
              size: 48,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        );
      } catch (_) {
        return Center(
          child: Icon(
            _iconForCategory(category),
            size: 48,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        );
      }
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
  final bool isOwner;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ItemCard({
    required this.item,
    required this.isOwner,
    required this.onTap,
    this.onDelete,
  });

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
                    category: widget.item.category,
                  ),
                ),
                // ── Status badge ──
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
                // ── Time badge ──
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
                // ── Delete button (owner only) OR Bookmark (others) ──
                if (!_isClaimed)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: widget.isOwner
                        // ── DELETE button for owner ──
                        ? GestureDetector(
                            onTap: widget.onDelete,
                            child: Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEEEE),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          )
                        // ── BOOKMARK button for others ──
                        : Container(
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
                                _isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
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
                                  savedItemsNotifier.value = [
                                    ...saved,
                                    widget.item,
                                  ];
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
                                    backgroundColor: isDark
                                        ? Colors.grey[900]
                                        : null,
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
                            widget.item.locationDisplay,
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
                          // ── No Contact/Claim button for own posts ──
                          if (!widget.isOwner)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (widget.item.userId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatPage(
                                          targetUserId: widget.item.userId,
                                          relatedItemId: widget.item.id,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Reporter ID not found'),
                                      ),
                                    );
                                  }
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
                          if (!widget.isOwner) const SizedBox(width: 6),
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
