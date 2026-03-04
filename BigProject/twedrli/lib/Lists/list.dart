import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// ENUMS & DATA MODEL
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
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
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
// SAMPLE DATA
// ─────────────────────────────────────────────

final ValueNotifier<List<LostFoundItem>> allItemsNotifier = ValueNotifier([
  LostFoundItem(
    id: '1',
    title: 'Blue Hydro Flask',
    location: 'Faculté des Sciences',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    status: ItemStatus.lost,
    imagePath: 'assets/Bottle.png',
    description: 'Blue 32oz Hydro Flask with stickers',
    contactInfo: 'Contact: lostandfound@uni.edu',
    color: 'Blue',
    category: 'Water Bottle',
  ),
  LostFoundItem(
    id: '2',
    title: 'TI-84 Calculator',
    location: 'Bibliothèque Centrale',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    status: ItemStatus.found,
    imagePath: 'assets/calc.png',
    description: 'Texas Instruments TI-84 Plus',
    contactInfo: 'Claim at library front desk',
    color: 'Grey',
    category: 'Calculator',
  ),
  LostFoundItem(
    id: '3',
    title: 'Car Keys & Keychain',
    location: 'Le Restaurant Universitaire',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    status: ItemStatus.claimed,
    imagePath: 'assets/keys.png',
    description: 'Honda key with blue keychain',
    contactInfo: 'Claimed by Mohamed A.',
    color: 'Black',
    category: 'Car Keys',
  ),
  LostFoundItem(
    id: '4',
    title: 'MacBook Pro Charger',
    location: 'Département de Biologie',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    status: ItemStatus.found,
    imagePath: 'assets/charger.png',
    description: 'Apple 61W USB-C Charger',
    contactInfo: 'Available at security desk',
    color: 'White',
    category: 'Charger',
  ),
  LostFoundItem(
    id: '5',
    title: 'Wireless Headphones',
    location: 'Résidence Universitaire Mansourah 5',
    timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    status: ItemStatus.lost,
    imagePath: 'assets/headphones.png',
    description: 'Black Sony WH-1000XM4',
    contactInfo: 'Contact: fitnesscenter@uni.edu',
    color: 'Black',
    category: 'Headphones',
  ),
  LostFoundItem(
    id: '6',
    title: 'Black Umbrella',
    location: 'Faculté des Lettres et des Langues',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    status: ItemStatus.found,
    imagePath: 'assets/umbrella.png',
    description: 'Black umbrella with wooden handle',
    contactInfo: 'Claim at campus security',
    color: 'Black',
    category: 'Umbrella',
  ),
  LostFoundItem(
    id: '8',
    title: 'Samsung Earbuds Pro',
    location: 'Faculté des Sciences Islamiques',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    status: ItemStatus.lost,
    imagePath: 'assets/se.png',
    description: 'Samsung Galaxy Buds Pro in black',
    contactInfo: 'Contact: cs.faculty@uni.edu',
    color: 'Black',
    category: 'Earbuds',
  ),
  LostFoundItem(
    id: '9',
    title: 'iPhone 13',
    location: 'Le Restaurant Universitaire',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    status: ItemStatus.found,
    imagePath: 'assets/iphone.png',
    description: 'iPhone 13 with blue case',
    contactInfo: 'Contact: restaurant@uni.edu',
    color: 'Blue',
    category: 'Phone',
  ),
  LostFoundItem(
    id: '10',
    title: 'Student ID Card',
    location: 'Département de Psychologie',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    status: ItemStatus.lost,
    imagePath: 'assets/id.png',
    description: 'Student ID card - Name: John Doe',
    contactInfo: 'Contact: security@uni.edu',
    color: 'White',
    category: 'Student ID Card',
  ),
]);

final ValueNotifier<List<LostFoundItem>> savedItemsNotifier = ValueNotifier([]);

// ─────────────────────────────────────────────
// CAMPUS PLACES — matches map area (Université de Tlemcen, Mansourah)
// ─────────────────────────────────────────────

/// All pinnable places on the campus map.
/// These match what Nominatim returns for the Mansourah campus zone
/// (coords center: 34.8970, -1.3510).
final List<String> campusPlaces = [
  // ── Facultés ──────────────────────────────
  "Faculté des Sciences   ",
  "Faculté des Lettres et des Langues",
  "Faculté des Sciences Humaines et Sociales",
  "Faculté des Sciences Islamiques",
  "Faculté de Médecine",
  "Faculté de Droit et des Sciences Politiques",
  "Faculté des Sciences Économiques, Commerciales et des Sciences de Gestion",
  "Faculté de Technologie",

  // ── Départements ──────────────────────────
  "Département de Biologie",
  "Département de Chimie",
  "Département de Physique",
  "Département de Mathématiques",
  "Département de Langue Arabe et des Arts",
  "Département de Psychologie",
  "Département de Philosophie",
  "Département d'Histoire",
  "Département de Sociologie",
  "Département de Langue Française",
  "Département de Langue Anglaise",

  // ── Bâtiments & Services ──────────────────
  "Bibliothèque Centrale",
  "Centre d'Enseignement Intensif des Langues (CEIL)",
  "Fablab Université de Tlemcen",
  "Le Restaurant Universitaire",
  "Administration Centrale",
  "Rectorat",
  "Service de Scolarité",
  "Service des Œuvres Universitaires",
  "Infirmerie Universitaire",
  "Mosquée de l'Université",
  "Salle de Sport",
  "Terrain de Football",
  "Amphithéâtre Principal",
  "Salle de Conférences",
  "Centre de Calcul",

  // ── Résidences Universitaires ─────────────
  "Résidence Universitaire Mansourah 4 (Ahmed Mohammed)",
  "Résidence Universitaire Mansourah 5",
  "Résidence Universitaire Mansourah 7 (Ben Ahmed Abdel Kader)",
  "Résidence Universitaire Martyre Maliha Hamidou",

  // ── Entrées & Espaces extérieurs ──────────
  "Entrée Principale du Campus",
  "Parking Principal",
  "Arrêt de Bus Campus",
  "Allée Centrale du Campus",
];

// Keep campusZones as alias for backward compatibility
final List<String> campusZones = campusPlaces;

// ─────────────────────────────────────────────
// OBJECT TYPES
// ─────────────────────────────────────────────

final List<String> objectTypes = [
  "Phone",
  "Laptop",
  "Tablet",
  "Smart Watch",
  "Headphones",
  "Earbuds",
  "AirPods",
  "Charger",
  "Power Bank",
  "USB Flash Drive",
  "External Hard Drive",
  "Calculator",
  "Graphing Calculator",
  "Wallet",
  "Purse",
  "Backpack",
  "Handbag",
  "Student ID Card",
  "National ID Card",
  "Passport",
  "Driver's License",
  "Car Keys",
  "House Keys",
  "Locker Key",
  "Notebook",
  "Binder",
  "Textbook",
  "Lab Manual",
  "Folder",
  "Pen",
  "Pencil Case",
  "Glasses",
  "Sunglasses",
  "Water Bottle",
  "Lunch Box",
  "Jacket",
  "Sweater",
  "Hoodie",
  "Scarf",
  "Umbrella",
  "USB Cable",
  "Mouse",
  "Keyboard",
  "Scientific Instrument",
  "Lab Coat",
  "Access Card",
  "Sports Equipment",
  "Football",
  "Gym Bag",
  "Bluetooth Speaker",
  "Camera",
  "Microphone",
  "Tripod",
  "Project Report",
  "Presentation Clicker",
  "Diary",
  "Makeup Bag",
  "Medication",
];

final List<String> departements = [
  "Département de Biologie",
  "Département de Langue Arabe et des Arts",
  "Département de Psychologie",
  "Département de Philosophie",
  "Département d'Histoire",
  "Département de Chimie",
  "Département de Physique",
  "Département de Mathématiques",
  "Département de Sociologie",
  "Département de Langue Française",
  "Département de Langue Anglaise",
  "Département d'Informatique",
];
