import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/item_detail_screen.dart';

class TwedrliSearchScreen extends StatefulWidget {
  const TwedrliSearchScreen({super.key});

  @override
  State<TwedrliSearchScreen> createState() => _TwedrliSearchScreenState();
}

class _TwedrliSearchScreenState extends State<TwedrliSearchScreen> {
  String searchQuery = "";
  Color? selectedColor;
  bool isAllColorsSelected = true;
  String? selectedZone;
  String? selectedType;

  // ─── Normalize string (remove accents, lowercase) ────────────────────────
  String _normalize(String s) {
    const accents = 'àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿœ';
    const replaced = 'aaaaaaaceeeeiiiidnoooooouuuuybyoe';
    var result = s.toLowerCase();
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], replaced[i]);
    }
    return result;
  }

  // ─── Fuzzy location match ─────────────────────────────────────────────────
  bool _locationMatches(String itemLocation, String zone) {
    final a = _normalize(itemLocation);
    final b = _normalize(zone);
    return a.contains(b) || b.contains(a);
  }

  String _labelToApiCategory(String label) {
    const map = {
      'Phone': 'Electronics',
      'Laptop': 'Electronics',
      'Tablet': 'Electronics',
      'Smart Watch': 'Electronics',
      'Headphones': 'Electronics',
      'Earbuds': 'Electronics',
      'AirPods': 'Electronics',
      'Charger': 'Electronics',
      'Power Bank': 'Electronics',
      'USB Flash Drive': 'Electronics',
      'External Hard Drive': 'Electronics',
      'Calculator': 'Electronics',
      'Graphing Calculator': 'Electronics',
      'Camera': 'Electronics',
      'Microphone': 'Electronics',
      'Bluetooth Speaker': 'Electronics',
      'Presentation Clicker': 'Electronics',
      'Tripod': 'Electronics',
      'USB Cable': 'Electronics',
      'Mouse': 'Electronics',
      'Keyboard': 'Electronics',
      'Scientific Instrument': 'Electronics',
      'Wallet': 'Fashion',
      'Purse': 'Fashion',
      'Backpack': 'Fashion',
      'Handbag': 'Fashion',
      'Jacket': 'Fashion',
      'Sweater': 'Fashion',
      'Hoodie': 'Fashion',
      'Scarf': 'Fashion',
      'Glasses': 'Fashion',
      'Sunglasses': 'Fashion',
      'Lab Coat': 'Fashion',
      'Gym Bag': 'Sport',
      'Football': 'Sport',
      'Sports Equipment': 'Sport',
      'Notebook': 'Books',
      'Binder': 'Books',
      'Textbook': 'Books',
      'Lab Manual': 'Books',
      'Folder': 'Books',
      'Project Report': 'Books',
      'Diary': 'Books',
      'Pen': 'Books',
      'Pencil Case': 'Books',
      'Makeup Bag': 'Beauty',
      'Water Bottle': 'Home & Living',
      'Lunch Box': 'Home & Living',
      'Umbrella': 'Home & Living',
      'Medication': 'Home & Living',
      'Student ID Card': 'Other',
      'National ID Card': 'Other',
      'Passport': 'Other',
      'Driver\'s License': 'Other',
      'Car Keys': 'Other',
      'House Keys': 'Other',
      'Locker Key': 'Other',
      'Access Card': 'Other',
    };
    return map[label] ?? 'Other';
  }

  List<LostFoundItem> get filteredItems {
    return allItemsNotifier.value.where((item) {
      final matchesSearch =
          searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesType =
          selectedType == null ||
          item.category.toLowerCase() ==
              _labelToApiCategory(selectedType!).toLowerCase();

      final matchesZone =
          selectedZone == null ||
          _locationMatches(item.location, selectedZone!) ||
          _locationMatches(item.locationDisplay, selectedZone!);

      final matchesColor =
          isAllColorsSelected ||
          (selectedColor != null &&
              item.color.toLowerCase() ==
                  _colorToString(selectedColor!).toLowerCase());

      return matchesSearch && matchesType && matchesZone && matchesColor;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFD6DCE5);
    final inputBgColor = isDark ? Colors.grey[900]! : const Color(0xFFE9EDF2);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header (matches Activity / Chat style) ──
              Container(
                color: theme.appBarTheme.backgroundColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // ── Accent line ──
              Container(height: 2, color: theme.colorScheme.primary),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── Search Bar ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: inputBgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: isDark ? Colors.grey[500] : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (value) =>
                                  setState(() => searchQuery = value),
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText:
                                    "Search for lost items (e.g., 'Blue Wallet')...",
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(() => searchQuery = ''),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: isDark ? Colors.grey[500] : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ── Advanced Filters Header ──
                    Row(
                      children: [
                        Text(
                          "Advanced Filters",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() {
                            selectedType = null;
                            selectedZone = null;
                            isAllColorsSelected = true;
                            selectedColor = null;
                            searchQuery = "";
                          }),
                          child: Text(
                            "Clear All",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Object Type ──
                    Text(
                      "Object Type",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildObjectTypeField(
                      context,
                      isDark,
                      borderColor,
                      textColor,
                      secondaryTextColor,
                    ),

                    const SizedBox(height: 18),

                    // ── Campus Zone ──
                    Text(
                      "Campus Zone",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCampusZoneField(
                      context,
                      isDark,
                      borderColor,
                      textColor,
                      secondaryTextColor,
                    ),

                    const SizedBox(height: 18),

                    // ── Date Row ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "From Date",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _DateField(
                                isDark: isDark,
                                borderColor: borderColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "To Date",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _DateField(
                                isDark: isDark,
                                borderColor: borderColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Color ──
                    Text(
                      "Item Color",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAllColorsDot(),
                        _buildColorDot(Colors.black, isDark),
                        _buildColorDot(const Color(0xFFD6D6D6), isDark),
                        _buildColorDot(const Color(0xFF2E63D6), isDark),
                        _buildColorDot(const Color(0xFFE21E1E), isDark),
                        _buildColorDot(const Color(0xFFF3C200), isDark),
                        _buildColorDot(const Color(0xFF1B9E3F), isDark),
                        _buildColorDot(const Color(0xFF8A2BE2), isDark),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ── Apply Button ──
                    GestureDetector(
                      onTap: () => setState(() {}),
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Apply Filters & Search",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── Results Header ──
                    ValueListenableBuilder(
                      valueListenable: allItemsNotifier,
                      builder: (context, value, child) {
                        return Row(
                          children: [
                            Text(
                              "Matching Items (${filteredItems.length})",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Sorted by: Newest",
                              style: TextStyle(color: secondaryTextColor),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Items Grid ──
                    ValueListenableBuilder(
                      valueListenable: allItemsNotifier,
                      builder: (context, value, child) {
                        return filteredItems.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 40,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "No items match your filters",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isDark
                                              ? Colors.grey[500]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: 20,
                                      childAspectRatio: 0.72,
                                    ),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return _ItemCard(
                                    item: item,
                                    isDark: isDark,
                                    cardColor: cardColor,
                                    textColor: textColor,
                                    secondaryTextColor: secondaryTextColor,
                                  );
                                },
                              );
                      },
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Object Type Field ────────────────────────────────────────────────────

  Widget _buildObjectTypeField(
    BuildContext context,
    bool isDark,
    Color borderColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return GestureDetector(
      onTap: () => _openTypeSelector(context, isDark),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          color: isDark ? Colors.grey[900] : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedType ?? "Select type (Phone, Bag, ID...)",
                style: TextStyle(
                  color: selectedType == null ? secondaryTextColor : textColor,
                ),
              ),
            ),
            if (selectedType != null)
              GestureDetector(
                onTap: () => setState(() => selectedType = null),
                child: Icon(Icons.close, size: 16, color: secondaryTextColor),
              )
            else
              Icon(Icons.keyboard_arrow_down, color: secondaryTextColor),
          ],
        ),
      ),
    );
  }

  void _openTypeSelector(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final controller = TextEditingController();
        List<String> filteredList = List.from(objectTypes);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: 500,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: controller,
                        onChanged: (value) {
                          setModalState(() {
                            filteredList = objectTypes
                                .where(
                                  (item) => item.toLowerCase().contains(
                                    value.toLowerCase(),
                                  ),
                                )
                                .toList();
                          });
                        },
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search type...",
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.grey[500] : Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey[900] : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              filteredList[index],
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            onTap: () {
                              setState(
                                () => selectedType = filteredList[index],
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Campus Zone Field ────────────────────────────────────────────────────

  Widget _buildCampusZoneField(
    BuildContext context,
    bool isDark,
    Color borderColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return GestureDetector(
      onTap: () => _openZoneSelector(context, isDark),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          color: isDark ? Colors.grey[900] : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedZone ?? "Select location (Faculty, Campus...)",
                style: TextStyle(
                  color: selectedZone == null ? secondaryTextColor : textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selectedZone != null)
              GestureDetector(
                onTap: () => setState(() => selectedZone = null),
                child: Icon(Icons.close, size: 16, color: secondaryTextColor),
              )
            else
              Icon(Icons.keyboard_arrow_down, color: secondaryTextColor),
          ],
        ),
      ),
    );
  }

  void _openZoneSelector(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final controller = TextEditingController();
        List<String> filteredList = List.from(campusPlaces);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 500,
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        setModalState(() {
                          filteredList = campusPlaces
                              .where(
                                (zone) => _normalize(
                                  zone,
                                ).contains(_normalize(value)),
                              )
                              .toList();
                        });
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search zone...",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.grey[500] : Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: isDark ? Colors.grey[500] : Colors.grey,
                            size: 18,
                          ),
                          title: Text(
                            filteredList[index],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          onTap: () {
                            setState(() => selectedZone = filteredList[index]);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Color Widgets ────────────────────────────────────────────────────────

  Widget _buildAllColorsDot() {
    return GestureDetector(
      onTap: () => setState(() {
        isAllColorsSelected = true;
        selectedColor = null;
      }),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isAllColorsSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              'All',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, bool isDark) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() {
        selectedColor = color;
        isAllColorsSelected = false;
      }),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: color == const Color(0xFFD6D6D6) && isDark
              ? Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  String _colorToString(Color color) {
    if (color == Colors.black) return "Black";
    if (color == const Color(0xFFD6D6D6)) return "White";
    if (color == const Color(0xFF2E63D6)) return "Blue";
    if (color == const Color(0xFFE21E1E)) return "Red";
    if (color == const Color(0xFFF3C200)) return "Yellow";
    if (color == const Color(0xFF1B9E3F)) return "Green";
    if (color == const Color(0xFF8A2BE2)) return "Purple";
    return "";
  }
}

// ─── Date Field ───────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final bool isDark;
  final Color borderColor;

  const _DateField({required this.isDark, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        color: isDark ? Colors.grey[900] : Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "mm/dd/yyyy",
              style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey),
            ),
          ),
          Icon(
            Icons.calendar_today,
            size: 18,
            color: isDark ? Colors.grey[500] : Colors.grey,
          ),
        ],
      ),
    );
  }
}

// ─── Item Card ────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final LostFoundItem item;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;

  const _ItemCard({
    required this.item,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
  });

  Widget _buildImage() {
    bool isBase64(String s) {
      if (s.length % 4 != 0) return false;
      return RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(s);
    }

    IconData iconForCategory(String cat) {
      switch (cat.toLowerCase()) {
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

    Color colorForCategory(String cat) {
      switch (cat.toLowerCase()) {
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

    Widget placeholder() => Container(
      color: isDark ? Colors.grey[800] : colorForCategory(item.category),
      child: Center(
        child: Icon(
          iconForCategory(item.category),
          size: 48,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
    );

    if (item.imagePath.isEmpty) return placeholder();

    if (item.imagePath.startsWith('http://') ||
        item.imagePath.startsWith('https://')) {
      return Image.network(
        item.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: isDark ? Colors.grey[800] : colorForCategory(item.category),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }

    if (item.imagePath.startsWith('data:image') || isBase64(item.imagePath)) {
      try {
        final bytes = base64Decode(
          item.imagePath.contains(',')
              ? item.imagePath.split(',').last
              : item.imagePath,
        );
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder(),
        );
      } catch (_) {
        return placeholder();
      }
    }

    if (item.imagePath.startsWith('assets/')) {
      return Image.asset(
        item.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
      );
    }

    return Image.file(
      File(item.imagePath),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLost = item.status == ItemStatus.lost;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: _buildImage(),
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
                        color:
                            (item.status == ItemStatus.lost
                                    ? const Color(0xFFE53935)
                                    : item.status == ItemStatus.found
                                    ? const Color(0xFF1E88E5)
                                    : const Color(0xFF43A047))
                                .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status.name.toUpperCase(),
                        style: TextStyle(
                          color: item.status == ItemStatus.lost
                              ? const Color(0xFFE53935)
                              : item.status == ItemStatus.found
                              ? const Color(0xFF1E88E5)
                              : const Color(0xFF43A047),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.timeAgo,
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.locationDisplay,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
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
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description.isNotEmpty
                      ? item.description
                      : 'No description provided',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.contactInfo.isNotEmpty
                              ? item.contactInfo
                              : 'No contact info',
                          style: TextStyle(fontSize: 14, color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (item.status != ItemStatus.claimed)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
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
              ],
            ),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.transparent
                  : Colors.black.withOpacity(.05),
              blurRadius: 10,
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
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: _buildImage(),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isLost
                          ? const Color(0xFFE53935)
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLost ? "LOST" : "FOUND",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.locationDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
