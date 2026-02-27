import 'package:flutter/material.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/home.dart';
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

  List<LostFoundItem> get filteredItems {
    return allItemsNotifier.value.where((item) {
      final matchesSearch =
          searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesType =
          selectedType == null ||
          item.category.toLowerCase() == selectedType!.toLowerCase();

      final matchesZone = selectedZone == null || item.location == selectedZone;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
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
                    const Icon(Icons.search, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 8),
                    const Text(
                      "Twedrli Search",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF1E88E5),
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
                    color: const Color(0xFFE9EDF2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText:
                                "Search for lost items (e.g., 'Blue Wallet')...",
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
                    const Text(
                      "Advanced Filters",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                      child: const Text(
                        "Clear All",
                        style: TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Object Type",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                buildObjectTypeField(context),
                const SizedBox(height: 18),

                const Text(
                  "Campus Zone",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                buildCampusZoneField(context),
                const SizedBox(height: 18),

                const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "From Date",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          DateField(),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "To Date",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          DateField(),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Item Color",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildAllColorsDot(),
                    buildColorDot(Colors.black),
                    buildColorDot(const Color(0xFFD6D6D6)),
                    buildColorDot(const Color(0xFF2E63D6)),
                    buildColorDot(const Color(0xFFE21E1E)),
                    buildColorDot(const Color(0xFFF3C200)),
                    buildColorDot(const Color(0xFF1B9E3F)),
                    buildColorDot(const Color(0xFF8A2BE2)),
                  ],
                ),

                const SizedBox(height: 25),

                /// APPLY BUTTON
                GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Sorted by: Newest",
                      style: TextStyle(color: Colors.grey),
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
                    return ItemCard(item: item);
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

  Widget buildObjectTypeField(BuildContext context) {
    return GestureDetector(
      onTap: () => _openTypeSelector(context),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD6DCE5)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedType ?? "Select type (Phone, Bag, ID...)",
                style: TextStyle(
                  color: selectedType == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  void _openTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        TextEditingController controller = TextEditingController();
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
                        decoration: InputDecoration(
                          hintText: "Search type...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredList[index]),
                            onTap: () {
                              setState(() {
                                selectedType = filteredList[index];
                              });
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

  Widget buildCampusZoneField(BuildContext context) {
    return GestureDetector(
      onTap: () => _openZoneSelector(context),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD6DCE5)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedZone ?? "Select location (Faculty, Campus...)",
                style: TextStyle(
                  color: selectedZone == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  void _openZoneSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        TextEditingController controller = TextEditingController();
        List<String> filteredList = List.from(campusZones);

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
                          filteredList = campusZones
                              .where(
                                (zone) => zone.toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search zone...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredList[index]),
                          onTap: () {
                            setState(() {
                              selectedZone = filteredList[index];
                            });
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
              ? Border.all(color: const Color(0xFF1E88E5), width: 2)
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

  Widget buildColorDot(Color color) {
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
              ? Border.all(color: const Color(0xFF1E88E5), width: 2)
              : null,
        ),
        child: CircleAvatar(radius: 16, backgroundColor: color),
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

class DateField extends StatelessWidget {
  const DateField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DCE5)),
        color: Colors.white,
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text("mm/dd/yyyy", style: TextStyle(color: Colors.grey)),
          ),
          Icon(Icons.calendar_today, size: 18),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final LostFoundItem item;

  const ItemCard({super.key, required this.item});

  String getTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = item.status == ItemStatus.lost;

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
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
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
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No Image',
                                style: TextStyle(
                                  color: Colors.grey[600],
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
                          ? const Color.fromARGB(255, 255, 0, 0)
                          : const Color(0xFF1E88E5),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E88E5),
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
