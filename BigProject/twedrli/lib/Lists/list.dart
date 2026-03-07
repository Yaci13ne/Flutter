import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ─────────────────────────────────────────────
// ENUMS
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

// ─────────────────────────────────────────────
// LOCAL IMAGE CACHE
// Stores base64 images by item ID so they survive
// fetchProducts() re-runs (server may not return img_url).
// ─────────────────────────────────────────────
final Map<String, String> _localImageCache = {};

/// Call this after a successful POST to remember the image locally.
void cacheImageForItem(String itemId, String base64DataUri) {
  if (itemId.isNotEmpty && base64DataUri.isNotEmpty) {
    _localImageCache[itemId] = base64DataUri;
    debugPrint(
      '💾 Cached image for item $itemId (${base64DataUri.length} chars)',
    );
  }
}

/// Returns the best available image for an item:
/// server URL if available, otherwise local cache.
String resolveImage(String itemId, String serverImgUrl) {
  // Server returned a real value — use it
  if (serverImgUrl.isNotEmpty) return serverImgUrl;
  // Fall back to local cache
  final cached = _localImageCache[itemId];
  if (cached != null && cached.isNotEmpty) {
    debugPrint('🔁 Using cached image for item $itemId');
    return cached;
  }
  return '';
}

// ─────────────────────────────────────────────
// IMAGE URL NORMALISATION
// ─────────────────────────────────────────────
String _normaliseImageUrl(dynamic raw) {
  if (raw == null) return '';
  final s = raw.toString().trim();
  if (s.isEmpty || s == 'null') return '';
  if (s.startsWith('data:image')) return s;
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  // Raw base64 without data URI prefix
  if (_looksLikeBase64(s)) return 'data:image/jpeg;base64,$s';
  return s;
}

bool _looksLikeBase64(String s) {
  if (s.length < 20) return false;
  return RegExp(
    r'^[A-Za-z0-9+/\r\n]+=*$',
  ).hasMatch(s.replaceAll('\n', '').replaceAll('\r', ''));
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

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
  final int? userId;

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String get locationDisplay {
    const map = {
      'info': 'Faculté d\'Informatique',
      'sm': 'Faculté des Sciences et Mathématiques',
      'st': 'Faculté des Sciences et Technologie',
      'math': 'Faculté des Mathématiques',
    };
    return map[location] ?? location;
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
    this.userId,
  });

  factory LostFoundItem.fromJson(
    Map<String, dynamic> json, {
    String reporterName = '',
  }) {
    ItemStatus parseStatus(String? s) {
      switch (s) {
        case 'found':
          return ItemStatus.found;
        case 'claimed':
          return ItemStatus.claimed;
        default:
          return ItemStatus.lost;
      }
    }

    final id = json['id']?.toString() ?? '';
    final userId = json['user_id'] as int?;

    // ── Safely read title — try common field names ───────────────────────────
    final title =
        (json['title'] ?? json['name'] ?? json['item_title'] ?? 'Untitled')
            .toString()
            .trim();

    final contact = reporterName.isNotEmpty
        ? 'Reported by $reporterName'
        : 'Reported by user #${json['user_id']}';

    // ── Normalise image, then apply local cache fallback ────────────────────
    final serverImg = _normaliseImageUrl(json['img_url']);
    final finalImg = resolveImage(id, serverImg);

    debugPrint(
      '📷 id=$id title="$title" img=${finalImg.isEmpty ? "none" : finalImg.substring(0, finalImg.length.clamp(0, 50))}',
    );

    return LostFoundItem(
      id: id,
      title: title.isEmpty ? 'Untitled' : title,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      status: parseStatus(json['status'] as String?),
      location: json['location']?.toString() ?? '',
      timestamp: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      imagePath: finalImg,
      contactInfo: contact,
      color: json['color']?.toString() ?? '',
      userId: userId,
    );
  }
}

// ─────────────────────────────────────────────
// NOTIFIERS
// ─────────────────────────────────────────────

final ValueNotifier<List<LostFoundItem>> allItemsNotifier = ValueNotifier([]);
final ValueNotifier<List<LostFoundItem>> savedItemsNotifier = ValueNotifier([]);
final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(true);
final ValueNotifier<String> errorNotifier = ValueNotifier('');

final ValueNotifier<int?> loggedInUserIdNotifier = ValueNotifier<int?>(null);
final ValueNotifier<String> loggedInUserNameNotifier = ValueNotifier<String>(
  '',
);
final ValueNotifier<String> loggedInTokenNotifier = ValueNotifier<String>('');
final ValueNotifier<String> loggedInDepartmentNotifier = ValueNotifier<String>(
  '',
);

// ─────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────

class TwedrliApi {
  static const String _base = 'https://twedrliapi.linguaflo.me';

  static Future<void> fetchProducts() async {
    isLoadingNotifier.value = true;
    errorNotifier.value = '';
    try {
      final results = await Future.wait([
        http
            .get(Uri.parse('$_base/products'))
            .timeout(const Duration(seconds: 15)),
        http
            .get(Uri.parse('$_base/users'))
            .timeout(const Duration(seconds: 15)),
      ]);

      final productsRes = results[0];
      final usersRes = results[1];

      final Map<int, String> userNames = {};
      if (usersRes.statusCode == 200) {
        final List<dynamic> userList = json.decode(usersRes.body);
        for (final u in userList) {
          userNames[u['id'] as int] = u['name'] ?? 'Unknown';
        }
      }

      if (productsRes.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(productsRes.body);
        allItemsNotifier.value = jsonList.map((e) {
          final map = e as Map<String, dynamic>;
          final userId = map['user_id'] as int?;
          final name = userId != null ? (userNames[userId] ?? '') : '';
          return LostFoundItem.fromJson(map, reporterName: name);
        }).toList();
      } else {
        errorNotifier.value = 'Server error ${productsRes.statusCode}';
      }
    } catch (e) {
      errorNotifier.value =
          'Could not reach the server. Check your connection.';
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  static Future<bool> deleteProduct(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_base/products/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('DELETE /products/$id → ${response.statusCode}');
      // Also remove from local image cache
      _localImageCache.remove(id);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('DELETE error: $e');
      return false;
    }
  }
}

// ─────────────────────────────────────────────
// CAMPUS PLACES
// ─────────────────────────────────────────────

final List<String> campusPlaces = [
  "Faculté des Sciences",
  "Faculté des Lettres et des Langues",
  "Faculté des Sciences Humaines et Sociales",
  "Faculté des Sciences Islamiques",
  "Faculté de Droit et des Sciences Politiques",
  "Faculté des Sciences Économiques, Commerciales et des Sciences de Gestion",
  "Faculté de Technologie",
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
  "Résidence Universitaire Mansourah 4 (Ahmed Mohammed)",
  "Résidence Universitaire Mansourah 5",
  "Résidence Universitaire Mansourah 7 (Ben Ahmed Abdel Kader)",
  "Résidence Universitaire Martyre Maliha Hamidou",
  "Entrée Principale du Campus",
  "Parking Principal",
  "Arrêt de Bus Campus",
  "Allée Centrale du Campus",
];

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
