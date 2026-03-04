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

  // ─── Fuzzy location match ─────────────────────────────────────────────────
  /// Returns true if the item's location "contains" the selected zone or
  /// vice-versa, case-insensitively and accent-insensitively.
  bool _locationMatches(String itemLocation, String zone) {
    final a = _normalize(itemLocation);
    final b = _normalize(zone);
    return a.contains(b) || b.contains(a);
  }

  /// Strip accents and lowercase so "Faculté" == "faculte".
  String _normalize(String s) {
    const accents = 'àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿœ';
    const replaced = 'aaaaaaaceeeeiiiidnoooooouuuuybyoe';
    var result = s.toLowerCase();
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], replaced[i]);
    }
    return result;
  }

  List<LostFoundItem> get filteredItems {
    return allItemsNotifier.value.where((item) {
      final matchesSearch =
          searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesType =
          selectedType == null ||
          item.category.toLowerCase() == selectedType!.toLowerCase();

      // ← fuzzy match instead of exact equality
      final matchesZone =
          selectedZone == null ||
          _locationMatches(item.location, selectedZone!);

      final matchesColor =
          isAllColorsSelected ||
          (selectedColor != null &&
              item.color.toLowerCase() ==
                  _colorToString(selectedColor!).toLowerCase());

      return matchesSearch && matchesType && matchesZone && matchesColor;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFD6DCE5);
    final inputBgColor = isDark ? Colors.grey[900]! : const Color(0xFFE9EDF2);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                /// HEADER
                Row(
                  children: [
                    Icon(Icons.search, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Twedrli Search",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

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
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText:
                                "Search for lost items (e.g., 'Blue Wallet')...",
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[600] : Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                /// ADVANCED FILTERS
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
                      onTap: () {
                        setState(() {
                          selectedType = null;
                          selectedZone = null;
                          isAllColorsSelected = true;
                          selectedColor = null;
                          searchQuery = "";
                        });
                      },
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

                Text(
                  "Object Type",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                buildObjectTypeField(
                  context,
                  isDark,
                  borderColor,
                  textColor,
                  secondaryTextColor!,
                ),
                const SizedBox(height: 18),

                Text(
                  "Campus Zone",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                buildCampusZoneField(
                  context,
                  isDark,
                  borderColor,
                  textColor,
                  secondaryTextColor,
                ),
                const SizedBox(height: 18),

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
                          DateField(isDark: isDark, borderColor: borderColor),
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
                          DateField(isDark: isDark, borderColor: borderColor),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

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
                    buildAllColorsDot(),
                    buildColorDot(Colors.black, isDark),
                    buildColorDot(const Color(0xFFD6D6D6), isDark),
                    buildColorDot(const Color(0xFF2E63D6), isDark),
                    buildColorDot(const Color(0xFFE21E1E), isDark),
                    buildColorDot(const Color(0xFFF3C200), isDark),
                    buildColorDot(const Color(0xFF1B9E3F), isDark),
                    buildColorDot(const Color(0xFF8A2BE2), isDark),
                  ],
                ),

                const SizedBox(height: 25),

                /// APPLY BUTTON
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

                /// MATCHING ITEMS HEADER
                Row(
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
                ),

                const SizedBox(height: 20),

                /// ITEMS GRID
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ItemCard(
                      item: item,
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    );
                  },
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Object Type Field ────────────────────────────────────────────────────

  Widget buildObjectTypeField(
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

  Widget buildCampusZoneField(
    BuildContext context,
    bool isDark,
    Color borderColor,
    Color textColor,
    Color? secondaryTextColor,
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
              ),
            ),
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

  Widget buildAllColorsDot() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isAllColorsSelected = true;
          selectedColor = null;
        });
      },
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

  Widget buildColorDot(Color color, bool isDark) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
          isAllColorsSelected = false;
        });
      },
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
    if (color == Colors.black) return "black";
    if (color == const Color(0xFFD6D6D6)) return "white";
    if (color == const Color(0xFF2E63D6)) return "blue";
    if (color == const Color(0xFFE21E1E)) return "red";
    if (color == const Color(0xFFF3C200)) return "yellow";
    if (color == const Color(0xFF1B9E3F)) return "green";
    if (color == const Color(0xFF8A2BE2)) return "purple";
    return "";
  }
}

// ─── Date Field ───────────────────────────────────────────────────────────────

class DateField extends StatelessWidget {
  final bool isDark;
  final Color borderColor;

  const DateField({super.key, required this.isDark, required this.borderColor});

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

class ItemCard extends StatelessWidget {
  final LostFoundItem item;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;

  const ItemCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
  });

  String getTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) return "${difference.inMinutes} min ago";
    if (difference.inHours < 24) return "${difference.inHours} hours ago";
    return "${difference.inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    final isLost = item.status == ItemStatus.lost;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
        );
      },
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
                  child: Image.asset(
                    item.imagePath,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[600],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No Image',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                          item.location,
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
                    getTimeAgo(item.timestamp),
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
