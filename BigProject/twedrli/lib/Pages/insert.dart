import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/map.dart' hide LostFoundItem;

void main() {
  runApp(const TwedrliApp());
}

class TwedrliApp extends StatelessWidget {
  const TwedrliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twedrli',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF29B6F6),
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: CreatePostScreen(userId: loggedInUserIdNotifier.value ?? 10),
    );
  }
}

// ─── Color Options ─────────────────────────────────────────────────────────────

class ItemColor {
  final Color color;
  final String label;
  final bool hasOutline;
  const ItemColor({
    required this.color,
    required this.label,
    this.hasOutline = false,
  });
}

const List<ItemColor> itemColors = [
  ItemColor(color: Color(0xFF1A1A1A), label: 'Black'),
  ItemColor(color: Colors.white, label: 'White', hasOutline: true),
  ItemColor(color: Color(0xFF3B82F6), label: 'Blue'),
  ItemColor(color: Color(0xFFEF4444), label: 'Red'),
  ItemColor(color: Color(0xFFF59E0B), label: 'Yellow'),
  ItemColor(color: Color(0xFF22C55E), label: 'Green'),
  ItemColor(color: Color(0xFF8B5CF6), label: 'Purple'),
  ItemColor(color: Color(0xFFEC4899), label: 'Pink'),
];

// ─── Create Post Screen ────────────────────────────────────────────────────────

class CreatePostScreen extends StatefulWidget {
  final int userId;
  const CreatePostScreen({super.key, required this.userId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? _selectedImage;
  bool _isLost = true;
  bool _isSubmitting = false;
  int _selectedColorIndex = 0;

  String _selectedLocation = '';
  String _selectedCategory = 'Phone';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickLocationFromMap() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const MapScreen(returnResult: true)),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _selectedLocation = result);
    }
  }

  // Maps campus display name → API location enum
  String _toApiLocation(String fullName) {
    final l = fullName.toLowerCase();
    if (l == 'info' || l == 'sm' || l == 'st' || l == 'math') return l;
    if (l.contains('informat')) return 'info';
    if (l.contains('technolog')) return 'st';
    if (l.contains('sciences et math')) return 'sm';
    if (l.contains('mathémat') || l.contains('math')) return 'math';
    // Return the original string if no match — backend stores it as-is
    return fullName;
  }

  // Maps objectTypes label → API category enum
  String _toApiCategory(String label) {
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
      'Makeup Bag': 'Beauty',
      'Water Bottle': 'Home & Living',
      'Lunch Box': 'Home & Living',
      'Umbrella': 'Home & Living',
      'Medication': 'Home & Living',
    };
    return map[label] ?? 'Other';
  }

Future<String?> _imageToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      debugPrint('📸 Image base64 length: ${b64.length}');
      return 'data:image/jpeg;base64,$b64';
    } catch (e) {
      debugPrint('Image encode error: $e');
      return null;
    }
  }


  // ── POST to API ────────────────────────────────────────────────────────────
  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // ── FIX: apply _toApiLocation() so location is stored correctly ──
      final apiLocation = _toApiLocation(_selectedLocation);

      final body = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _toApiCategory(_selectedCategory),
        'location': apiLocation, // ← FIXED: was _selectedLocation (raw string)
        'status': _isLost ? 'lost' : 'found',
        'user_id': widget.userId,
        'color': itemColors[_selectedColorIndex].label,
      };

      // Attach image if selected
      if (_selectedImage != null) {
        final b64 = await _imageToBase64(_selectedImage!);
        if (b64 != null) {
          body['img_url'] = b64;
          debugPrint('📦 img_url length: ${b64.length}');
        }
      }

      debugPrint('=== SUBMIT ===');
      debugPrint('title:    ${body['title']}');
      debugPrint('category: ${body['category']}');
      debugPrint('location: ${body['location']}');
      debugPrint('status:   ${body['status']}');
      debugPrint('user_id:  ${body['user_id']}');
      debugPrint('has img:  ${body.containsKey('img_url')}');

      final response = await http
          .post(
            Uri.parse('https://twedrliapi.linguaflo.me/products'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(
            const Duration(seconds: 30),
          ); // ← increased timeout for image upload

      debugPrint('STATUS:   ${response.statusCode}');
      debugPrint('RESPONSE: ${response.body}');
if (response.statusCode == 200 || response.statusCode == 201) {
        // Cache the image locally using the new item's ID from the response
        if (_selectedImage != null && body.containsKey('img_url')) {
          try {
            final decoded = json.decode(response.body);
            final newId = decoded['id']?.toString() ?? '';
            if (newId.isNotEmpty) {
              cacheImageForItem(newId, body['img_url'] as String);
            }
          } catch (_) {}
        }
        // Refresh the global list so home + profile update immediately
        await TwedrliApi.fetchProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post submitted successfully!'),
              backgroundColor: Color(0xFF43A047),
            ),
          );
          Navigator.of(context).maybePop();
        }
      } else {
        if (mounted) {
          String serverMsg = response.body;
          try {
            final decoded = json.decode(response.body);
            serverMsg = decoded['message'] ?? decoded['error'] ?? response.body;
          } catch (_) {}
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error ${response.statusCode}: $serverMsg')),
          );
        }
      }
    } catch (e) {
      debugPrint('EXCEPTION: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not connect: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToggle(theme, isDark),
                    const SizedBox(height: 20),
                    _buildPhotoUpload(isDark),
                    const SizedBox(height: 24),
                    _buildLabel('Item Title', isDark),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'e.g. Blue Hydro Flask, Silver Keys',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Location', isDark),
                              const SizedBox(height: 8),
                              _buildLocationField(isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date', isDark),
                              const SizedBox(height: 8),
                              _buildDateField(isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Item Color', isDark),
                    const SizedBox(height: 12),
                    _buildColorSelector(isDark),
                    const SizedBox(height: 24),
                    _buildLabel('Category', isDark),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(isDark),
                    const SizedBox(height: 24),
                    _buildLabel('Description', isDark),
                    const SizedBox(height: 8),
                    _buildDescriptionField(isDark),
                    const SizedBox(height: 16),
                    _buildSecurityNote(isDark),
                    const SizedBox(height: 28),
                    _buildSubmitButton(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Icon(
              Icons.close,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Create New Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Drafts',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(ThemeData theme, bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _toggleTab('LOST', true, theme, isDark),
          _toggleTab('FOUND', false, theme, isDark),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, bool isLost, ThemeData theme, bool isDark) {
    final isActive = _isLost == isLost;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLost = isLost),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? Colors.grey[800] : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.transparent
                          : Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isActive
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.grey[600] : const Color(0xFF8BB8CC)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70, // ← compress at pick time too
          maxWidth: 800, // ← limit dimensions at pick time
          maxHeight: 800,
        );
        if (picked != null) setState(() => _selectedImage = File(picked.path));
      },
      child: Container(
        width: double.infinity,
        height: _selectedImage != null ? 200 : null,
        padding: _selectedImage != null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : const Color(0xFF7DD3F8),
            width: 1.5,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70,
                          maxWidth: 800,
                          maxHeight: 800,
                        );
                        if (picked != null) {
                          setState(() => _selectedImage = File(picked.path));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isDark ? Colors.white : const Color(0xFF29B6F6))
                                  .withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF29B6F6),
                            size: 26,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.blue[400]
                                  : const Color(0xFF29B6F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Add Item Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upload a clear photo of the item to help\nothers identify it quickly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey[500]
                          : const Color(0xFF8BA5B5),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[600] : const Color(0xFFB0C4CE),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : const Color(0xFFF8FBFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[800]! : const Color(0xFFDDE8EE),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.blue[400]! : const Color(0xFF29B6F6),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField(bool isDark) {
    final hasLocation = _selectedLocation.isNotEmpty;
    return GestureDetector(
      onTap: _pickLocationFromMap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : const Color(0xFFF8FBFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasLocation
                ? (isDark ? Colors.blue[400]! : const Color(0xFF29B6F6))
                : (isDark ? Colors.grey[800]! : const Color(0xFFDDE8EE)),
            width: hasLocation ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasLocation
                  ? Icons.location_pin
                  : Icons.add_location_alt_outlined,
              color: hasLocation
                  ? (isDark ? Colors.blue[400] : const Color(0xFF29B6F6))
                  : (isDark ? Colors.grey[600] : const Color(0xFFB0C4CE)),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasLocation ? _selectedLocation : 'Pin on map…',
                style: TextStyle(
                  fontSize: 13,
                  color: hasLocation
                      ? (isDark ? Colors.white70 : const Color(0xFF1A1A2E))
                      : (isDark ? Colors.grey[600] : const Color(0xFFB0C4CE)),
                  fontWeight: hasLocation ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasLocation)
              GestureDetector(
                onTap: () => setState(() => _selectedLocation = ''),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isDark ? Colors.grey[500] : const Color(0xFFB0C4CE),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : const Color(0xFFDDE8EE),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? Colors.grey[500] : const Color(0xFF8BA5B5),
            size: 20,
          ),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
          ),
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
          items: objectTypes
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ),
    );
  }

  Widget _buildDateField(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(
                primary: isDark ? Colors.blue[400]! : const Color(0xFF29B6F6),
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            _dateController.text =
                '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : const Color(0xFFF8FBFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : const Color(0xFFDDE8EE),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _dateController.text.isEmpty
                    ? 'mm/dd/yyyy'
                    : _dateController.text,
                style: TextStyle(
                  fontSize: 14,
                  color: _dateController.text.isEmpty
                      ? (isDark ? Colors.grey[600] : const Color(0xFFB0C4CE))
                      : (isDark ? Colors.white70 : const Color(0xFF1A1A2E)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector(bool isDark) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemColors.length,
        itemBuilder: (ctx, i) {
          final c = itemColors[i];
          final isSelected = _selectedColorIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedColorIndex = i),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                      border: c.hasOutline
                          ? Border.all(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : const Color(0xFFDDE8EE),
                              width: 1.5,
                            )
                          : isSelected
                          ? Border.all(
                              color: isDark
                                  ? Colors.blue[400]!
                                  : const Color(0xFF29B6F6),
                              width: 2.5,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: c.color.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: c.hasOutline
                                ? (isDark
                                      ? Colors.white70
                                      : const Color(0xFF1A1A2E))
                                : Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? (isDark
                                ? Colors.blue[400]
                                : const Color(0xFF29B6F6))
                          : (isDark
                                ? Colors.grey[500]
                                : const Color(0xFF8BA5B5)),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return TextField(
      controller: _descController,
      maxLines: 5,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        hintText: 'Mention unique marks, stickers, or\nbrand details...',
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[600] : const Color(0xFFB0C4CE),
          fontSize: 14,
          height: 1.5,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : const Color(0xFFF8FBFD),
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[800]! : const Color(0xFFDDE8EE),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.blue[400]! : const Color(0xFF29B6F6),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityNote(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? Colors.blue[400] : const Color(0xFF29B6F6),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "For security, don't mention high-value specific details like serial numbers or passcode clues. You can verify ownership through private chat.",
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.grey[400] : const Color(0xFF5A8099),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitPost,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isSubmitting
                ? [Colors.grey, Colors.grey]
                : [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withBlue(150),
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: _isSubmitting
              ? []
              : [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: _isSubmitting
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Submit Post',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }

  DateTime _parseDate(String text) {
    final parts = text.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
