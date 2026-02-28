import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  final List<TutorialSection> sections = const [
    TutorialSection(
      title: 'How to Report a Lost Item',
      steps: [
        TutorialItemData(
          imagePath: 'assets/tutorial/lost_step1.png',
          title: 'Step 1: Open Create Post',
          description:
              'Tap the + button at the bottom center of the home screen to start creating a new post.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/lost_step2.png',
          title: 'Step 2: Select LOST',
          description:
              'Make sure "LOST" is selected at the top toggle. This tells others you\'re looking for this item.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/lost_step3.png',
          title: 'Step 3: Add Photos',
          description:
              'Tap the photo upload area to add clear images of your lost item. Good photos help others identify it faster.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/lost_step4.png',
          title: 'Step 4: Fill Details',
          description:
              'Enter the item title, location where you lost it, date, color, and a detailed description with unique marks.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/lost_step5.png',
          title: 'Step 5: Submit Post',
          description:
              'Tap "Submit Post" to publish your lost item. You\'ll be notified if someone finds a matching item.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Report a Found Item',
      steps: [
        TutorialItemData(
          imagePath: 'assets/tutorial/found_step1.png',
          title: 'Step 1: Open Create Post',
          description:
              'Tap the + button at the bottom center to create a new post for the item you found.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/found_step2.png',
          title: 'Step 2: Select FOUND',
          description:
              'Toggle to "FOUND" at the top. This lets everyone know you have an item that needs its owner.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/found_step3.png',
          title: 'Step 3: Add Photos',
          description:
              'Upload clear photos of the found item. Make sure to capture any identifying features.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/found_step4.png',
          title: 'Step 4: Add Location',
          description:
              'Enter where you found the item. This helps the owner know where to look or meet.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/found_step5.png',
          title: 'Step 5: Submit Post',
          description:
              'Submit the found item post. The system will try to match it with lost item reports.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Search for Items',
      steps: [
        TutorialItemData(
          imagePath: 'assets/tutorial/search_step1.png',
          title: 'Step 1: Open Search',
          description:
              'Tap the "Search" tab at the bottom navigation bar to access the advanced search screen.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/search_step2.png',
          title: 'Step 2: Enter Keywords',
          description:
              'Type keywords like "blue water bottle" or "black keys" to find specific items.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/search_step3.png',
          title: 'Step 3: Apply Filters',
          description:
              'Use the advanced filters to narrow down by object type, campus zone, date, and color.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/search_step4.png',
          title: 'Step 4: View Results',
          description:
              'Browse through the matching items. Tap any item to see full details and contact information.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Claim an Item',
      steps: [
        TutorialItemData(
          imagePath: 'assets/tutorial/claim_step1.png',
          title: 'Step 1: Find Your Item',
          description:
              'Search for your lost item or browse the found items section until you spot what you\'re looking for.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/claim_step2.png',
          title: 'Step 2: Open Item Details',
          description:
              'Tap on the item card to open the detailed view with all information and photos.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/claim_step3.png',
          title: 'Step 3: Tap Claim Button',
          description:
              'If the item matches yours, tap the "Claim Item" button at the bottom of the details screen.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/claim_step4.png',
          title: 'Step 4: Contact Finder',
          description:
              'The app will connect you with the finder via chat. Describe your item to verify ownership.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/claim_step5.png',
          title: 'Step 5: Arrange Pickup',
          description:
              'Once ownership is verified, arrange a safe meeting spot on campus to collect your item.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Use the Activity Feed',
      steps: [
        TutorialItemData(
          imagePath: 'assets/tutorial/activity_step1.png',
          title: 'Step 1: Open Activity',
          description:
              'Tap the "Activity" tab at the bottom navigation bar to see your notifications and updates.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/activity_step2.png',
          title: 'Step 2: Check Notifications',
          description:
              'View all your activity including post approvals, match alerts, messages, and system updates.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/activity_step3.png',
          title: 'Step 3: Quick Navigation',
          description:
              'Use the buttons at the top to quickly navigate to Chat, Notifications, Announcements, and Updates.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/activity_step4.png',
          title: 'Step 4: Mark as Read',
          description:
              'Unread items have a colored indicator. Tap "Mark all read" to clear them or read them individually.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Save Items',
      steps: [
        TutorialItemData(
          imagePath: 'assets/tutorial/save_step1.png',
          title: 'Step 1: Find Item to Save',
          description:
              'Browse the home screen or search results to find an item you want to bookmark for later.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/save_step2.png',
          title: 'Step 2: Tap Bookmark Icon',
          description:
              'On each item card, tap the bookmark icon in the bottom right corner to save it to your collection.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/save_step3.png',
          title: 'Step 3: View Saved Items',
          description:
              'Go to your Profile and tap the "Saved Items" tab to see all items you\'ve bookmarked.',
        ),
        TutorialItemData(
          imagePath: 'assets/tutorial/save_step4.png',
          title: 'Step 4: Manage Saved Items',
          description:
              'Tap the bookmark icon again to remove items from your saved collection when no longer needed.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use Twedrli'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  section.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...section.steps.map(
                (item) => TutorialItem(
                  item: item,
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              if (index < sections.length - 1) ...[
                Divider(
                  thickness: 2,
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}

class TutorialSection {
  final String title;
  final List<TutorialItemData> steps;

  const TutorialSection({required this.title, required this.steps});
}

class TutorialItemData {
  final String imagePath;
  final String title;
  final String description;

  const TutorialItemData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

// VERSION 1: WITH PLACEHOLDERS (USE THIS NOW)
class TutorialItem extends StatelessWidget {
  final TutorialItemData item;
  final bool isDark;
  final Color primaryColor;

  const TutorialItem({
    super.key,
    required this.item,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: isDark ? 0 : 3,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          // Image placeholder with helpful message
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 60,
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Screenshot for ${item.title}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap the button below to add your screenshot',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[700] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Add screenshot for ${item.title}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_a_photo, size: 18),
                    label: const Text('Add Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}