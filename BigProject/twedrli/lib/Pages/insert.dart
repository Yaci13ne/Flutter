import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/home.dart';

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
      home: const CreatePostScreen(),
    );
  }
}

// ─── Color Options ────────────────────────────────────────────────────────────

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

// ─── Create Post Screen ───────────────────────────────────────────────────────

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? _selectedImage;
  bool _isLost = true;
  int _selectedColorIndex = 0;
  String _selectedZone = 'Faculté des Sciences';
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToggle(),
                    const SizedBox(height: 20),
                    _buildPhotoUpload(),
                    const SizedBox(height: 24),
                    _buildLabel('Item Title'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'e.g. Blue Hydro Flask, Silver Keys',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Campus Zone'),
                              const SizedBox(height: 8),
                              _buildDropdown(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date'),
                              const SizedBox(height: 8),
                              _buildDateField(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Item Color'),
                    const SizedBox(height: 12),
                    _buildColorSelector(),
                    const SizedBox(height: 24),
                    _buildLabel('Description'),
                    const SizedBox(height: 8),
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    _buildSecurityNote(),
                    const SizedBox(height: 28),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(Icons.close, color: Color(0xFF29B6F6), size: 24),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Create New Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Drafts',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF29B6F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Lost / Found Toggle ───────────────────────────────────────────────────

  Widget _buildToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
      ),
      child: Row(
        children: [_toggleTab('LOST', true), _toggleTab('FOUND', false)],
      ),
    );
  }

  Widget _toggleTab(String label, bool isLost) {
    final isActive = _isLost == isLost;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLost = isLost),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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
                    ? const Color(0xFF29B6F6)
                    : const Color(0xFF8BB8CC),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Photo Upload ──────────────────────────────────────────────────────────
Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (picked != null) {
          setState(() => _selectedImage = File(picked.path));
        }
      },
      child: Container(
        width: double.infinity,
        height: _selectedImage != null ? 200 : null,
        padding: _selectedImage != null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF7DD3F8), width: 1.5),
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
                          imageQuality: 85,
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF29B6F6).withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xFF29B6F6),
                            size: 26,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFF29B6F6),
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
                  const Text(
                    'Add Item Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Upload a clear photo of the item to help\nothers identify it quickly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8BA5B5),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  } // ─── Label ─────────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
        letterSpacing: -0.2,
      ),
    );
  }

  // ─── Text Field ────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0C4CE), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8FBFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE8EE), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 1.5),
        ),
      ),
    );
  }

  // ─── Dropdown ──────────────────────────────────────────────────────────────

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE8EE), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedZone,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF8BA5B5),
            size: 20,
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          items: campusZones
              .map((z) => DropdownMenuItem(value: z, child: Text(z)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedZone = val);
          },
        ),
      ),
    );
  }

  // ─── Date Field ────────────────────────────────────────────────────────────

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF29B6F6)),
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
          color: const Color(0xFFF8FBFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDE8EE), width: 1),
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
                      ? const Color(0xFFB0C4CE)
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Color Selector ────────────────────────────────────────────────────────

  Widget _buildColorSelector() {
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
                              color: const Color(0xFFDDE8EE),
                              width: 1.5,
                            )
                          : isSelected
                          ? Border.all(
                              color: const Color(0xFF29B6F6),
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
                                ? const Color(0xFF1A1A2E)
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
                          ? const Color(0xFF29B6F6)
                          : const Color(0xFF8BA5B5),
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

  // ─── Description Field ─────────────────────────────────────────────────────

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descController,
      maxLines: 5,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: 'Mention unique marks, stickers, or\nbrand details...',
        hintStyle: const TextStyle(
          color: Color(0xFFB0C4CE),
          fontSize: 14,
          height: 1.5,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FBFD),
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE8EE), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 1.5),
        ),
      ),
    );
  }

  // ─── Security Note ─────────────────────────────────────────────────────────

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF29B6F6),
            size: 18,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "For security, don't mention high-value specific details like serial numbers or passcode clues. You can verify ownership through private chat.",
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF5A8099),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Submit Button ─────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return GestureDetector(
onTap: () {
        final newItem = LostFoundItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          location: _selectedZone,
          timestamp: _dateController.text.isNotEmpty
              ? _parseDate(_dateController.text)
              : DateTime.now(),
          status: _isLost ? ItemStatus.lost : ItemStatus.found,
imagePath: _selectedImage?.path ?? '',  


        description: _descController.text,
          contactInfo: '',
          color: itemColors[_selectedColorIndex].label,
          category: '',
        );

        allItemsNotifier.value = [
          ...allItemsNotifier.value,
          newItem,
        ]; // triggers rebuild
        Navigator.of(context).maybePop();
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF29B6F6).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
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
      int.parse(parts[2]), // year
      int.parse(parts[0]), // month
      int.parse(parts[1]), // day
    );
  }
}
