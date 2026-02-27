import 'package:flutter/material.dart';

const Color kBackground = Color(0xFF0B1023);
const Color kCard = Color(0xFF121936);
const Color kAccent = Color(0xFF4C6FFF);
const Color kGradientStart = Color(0xFF4B4FD9);
const Color kGradientEnd = Color(0xFF7B5CFF);
const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Color(0xFF9CA3AF);

class ToolItem {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const ToolItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

final List<ToolItem> tools = [
  ToolItem(
    id: 'remove_bg',
    name: 'Remove BG',
    subtitle: 'Instant background removal',
    icon: Icons.auto_fix_high,
    iconBg: Color(0xFF1A1040),
    iconColor: Color(0xFF8B5CF6),
  ),
  ToolItem(
    id: 'ai_upscaler',
    name: 'AI Upscaler',
    subtitle: 'Increase image resolution',
    icon: Icons.hd,
    iconBg: Color(0xFF0F2040),
    iconColor: Color(0xFF3B82F6),
  ),
  ToolItem(
    id: 'expand_image',
    name: 'Expand Image',
    subtitle: 'Generative outer-painting',
    icon: Icons.open_in_full,
    iconBg: Color(0xFF0F2035),
    iconColor: Color(0xFF06B6D4),
  ),
  ToolItem(
    id: 'to_png',
    name: 'To PNG',
    subtitle: 'Export images as PNG',
    icon: Icons.image,
    iconBg: Color(0xFF0F2820),
    iconColor: Color(0xFF10B981),
  ),
  ToolItem(
    id: 'to_jpg',
    name: 'To JPG',
    subtitle: 'Export images as JPG',
    icon: Icons.photo,
    iconBg: Color(0xFF0D2818),
    iconColor: Color(0xFF34D399),
  ),
  ToolItem(
    id: 'word_to_pdf',
    name: 'Word to PDF',
    subtitle: 'Convert docs to PDF',
    icon: Icons.picture_as_pdf,
    iconBg: Color(0xFF1A1010),
    iconColor: Color(0xFFEF4444),
  ),
  ToolItem(
    id: 'pdf_to_word',
    name: 'PDF to Word',
    subtitle: 'Extract text from PDF',
    icon: Icons.description,
    iconBg: Color(0xFF1A1010),
    iconColor: Color(0xFFF97316),
  ),
  ToolItem(
    id: 'compress',
    name: 'Compress',
    subtitle: 'Reduce file size',
    icon: Icons.compress,
    iconBg: Color(0xFF101A28),
    iconColor: Color(0xFF60A5FA),
  ),

  ToolItem(
    id: 'crop',
    name: 'Crop',
    subtitle: 'Adjust framing',
    icon: Icons.crop,
    iconBg: Color(0xFF1A0F1A),
    iconColor: Color(0xFFEC4899),
  ),
  ToolItem(
    id: 'text_to_audio',
    name: 'Text to Audio',
    subtitle: 'Natural AI voices',
    icon: Icons.volume_up,
    iconBg: Color(0xFF1A1040),
    iconColor: Color(0xFFA78BFA),
  ),
  ToolItem(
    id: 'transcribe',
    name: 'Transcribe',
    subtitle: 'Audio to text converter',
    icon: Icons.mic,
    iconBg: Color(0xFF0F1A28),
    iconColor: Color(0xFF38BDF8),
  ),
  ToolItem(
    id: 'qr_maker',
    name: 'QR Maker',
    subtitle: 'Generate custom QR codes',
    icon: Icons.qr_code_2,
    iconBg: Color(0xFF0F2030),
    iconColor: Color(0xFF4C6FFF),
  ),
  ToolItem(
    id: 'zip_files',
    name: 'Zip Files',
    subtitle: 'Pack multiple files',
    icon: Icons.folder_zip,
    iconBg: Color(0xFF101818),
    iconColor: Color(0xFF2DD4BF),
  ),
  ToolItem(
    id: 'color_picker',
    name: 'Color Picker',
    subtitle: 'Extract HEX from images',
    icon: Icons.colorize,
    iconBg: Color(0xFF1A0A0A),
    iconColor: Color(0xFFF87171),
  ),
];
