import 'package:flutter/material.dart';
import 'package:helpdd/utils/constants.dart';
import 'package:helpdd/widgets/bottom_nav.dart';
import 'package:helpdd/widgets/featured_card.dart';
import 'package:helpdd/widgets/tool_card.dart';

import 'tool_screens/to_png_screen.dart';
import 'tool_screens/to_jpg_screen.dart';
import 'tool_screens/compress_screen.dart';
import 'tool_screens/resize_screen.dart';
import 'tool_screens/crop_screen.dart';
import 'tool_screens/qr_maker_screen.dart';
import 'tool_screens/text_to_audio_screen.dart';
import 'tool_screens/transcribe_screen.dart';
import 'tool_screens/zip_files_screen.dart';
import 'tool_screens/color_picker_screen.dart';
import 'tool_screens/remove_bg_screen.dart';
import 'tool_screens/ai_upscaler_screen.dart';
import 'tool_screens/expand_image_screen.dart';
import 'tool_screens/word_to_pdf_screen.dart';
import 'tool_screens/pdf_to_word_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _openTool(ToolItem tool) {
    Widget? screen;
    switch (tool.id) {
      case 'to_png':
        screen = const PictureToPngScreen();
        break;
      case 'to_jpg':
        screen = const PictureToJpgScreen();
        break;
      case 'compress':
        screen = const CompressScreen();
        break;
      case 'resize':
        screen = const ResizeScreen();
        break;
      case 'crop':
        screen = const CropScreen();
        break;
      case 'qr_maker':
        screen = const QrMakerScreen();
        break;
      case 'text_to_audio':
        screen = const TextToAudioScreen();
        break;
      case 'transcribe':
        screen = const TranscribeScreen();
        break;
      case 'zip_files':
        screen = const ZipFilesScreen();
        break;
      case 'color_picker':
        screen = const ColorPickerScreen();
        break;
      case 'remove_bg':
        screen = const RemoveBgScreen();
        break;
      case 'ai_upscaler':
        screen = const AiUpscalerScreen();
        break;
      case 'expand_image':
        screen = const ExpandImageScreen();
        break;
      case 'word_to_pdf':
        screen = const WordToPdfScreen();
        break;
      case 'pdf_to_word':
        screen = const PdfToWordScreen();
        break;
    }
    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(child: _buildHeader()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(child: _buildSearchBar()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: FeaturedCard(onTap: () => _openTool(tools[1])),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  sliver: SliverToBoxAdapter(child: _buildSectionHeader()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ToolCard(
                        tool: tools[index],
                        onTap: () => _openTool(tools[index]),
                      ),
                      childCount: tools.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.15,
                        ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: BottomNav(
                selectedIndex: _selectedIndex,
                onTap: (i) => setState(() => _selectedIndex = i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9A6C), Color(0xFFFF6B6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME BACK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Hello, User!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: kTextPrimary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: kTextSecondary, size: 20),
          const SizedBox(width: 10),
          Text(
            'Search 20+ tools...',
            style: TextStyle(color: kTextSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'All Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
        Text(
          'View All',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kAccent,
          ),
        ),
      ],
    );
  }
}
