import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>
    with SingleTickerProviderStateMixin {

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredTutorials = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildTutorials(AppLocalizations loc) {
    return [

      // ================= APP GUIDES =================

      {
        "title": loc.tutorialGettingStartedTitle,
        "type": "app_guide",
        "category": "app",
        "content": loc.tutorialGettingStartedContent,
        "icon": Icons.smartphone
      },
      {
        "title": loc.tutorialCropDetectionTitle,
        "type": "app_guide",
        "category": "app",
        "content": loc.tutorialCropDetectionContent,
        "icon": Icons.camera_alt
      },
      {
        "title": loc.tutorialFertilizerTitle,
        "type": "app_guide",
        "category": "app",
        "content": loc.tutorialFertilizerContent,
        "icon": Icons.calculate
      },
      {
        "title": loc.tutorialAssistantTitle,
        "type": "app_guide",
        "category": "app",
        "content": loc.tutorialAssistantContent,
        "icon": Icons.smart_toy
      },
      {
        "title": loc.tutorialMarketTitle,
        "type": "app_guide",
        "category": "app",
        "content": loc.tutorialMarketContent,
        "icon": Icons.location_on
      },

      // ================= FARMING GUIDES =================

      {
        "title": loc.tutorialOrganicTitle,
        "type": "text",
        "category": "farming",
        "content": loc.tutorialOrganicContent,
        "icon": Icons.eco
      },
      {
        "title": loc.tutorialIrrigationTitle,
        "type": "text",
        "category": "farming",
        "content": loc.tutorialIrrigationContent,
        "icon": Icons.water_drop
      },
      {
        "title": loc.tutorialIPMTitle,
        "type": "text",
        "category": "farming",
        "content": loc.tutorialIPMContent,
        "icon": Icons.bug_report
      },
      {
        "title": loc.tutorialRotationTitle,
        "type": "text",
        "category": "farming",
        "content": loc.tutorialRotationContent,
        "icon": Icons.refresh
      },
      {
        "title": loc.tutorialSoilTitle,
        "type": "text",
        "category": "farming",
        "content": loc.tutorialSoilContent,
        "icon": Icons.terrain
      },
      {
        "title": loc.tutorialFinanceTitle,
        "type": "text",
        "category": "farming",
        "content": loc.tutorialFinanceContent,
        "icon": Icons.account_balance
      },
      {
        "title": loc.tutorialMechanizationTitle,
        "type": "text",
        "category": "farming",
        "content": loc.tutorialMechanizationContent,
        "icon": Icons.construction
      },
      {
        "title": loc.tutorialWeatherTitle,
        "type": "text",
        "category": "farming",
        "content": loc.tutorialWeatherContent,
        "icon": Icons.wb_sunny
      },

      // ================= VIDEOS =================

      {
        "title": loc.tutorialWheatVideoTitle,
        "type": "video",
        "category": "farming",
        "url": "https://www.youtube.com/watch?v=MyfHCt7DDOg",
        "icon": Icons.play_circle
      },
      {
        "title": loc.tutorialTomatoVideoTitle,
        "type": "video",
        "category": "farming",
        "url": "https://www.youtube.com/watch?v=R65zFZ9-nPU",
        "icon": Icons.play_circle
      },
      {
        "title": loc.tutorialRotationVideoTitle,
        "type": "video",
        "category": "farming",
        "url": "https://www.youtube.com/watch?v=VcnzXJZxajQ",
        "icon": Icons.play_circle
      },

      // ================= IMAGES =================

      {
        "title": loc.tutorialPestImageTitle,
        "type": "image",
        "category": "farming",
        "imageUrl":
        "https://cdn.agroop.net/wp-content/uploads/2020/09/insectos-agricultura.jpg",
        "icon": Icons.image
      },
      {
        "title": loc.tutorialSoilImageTitle,
        "type": "image",
        "category": "farming",
        "imageUrl":
        "https://www.soils4teachers.org/files/s4t/images/SoilTexturesChart.jpg",
        "icon": Icons.image
      },
      {
        "title": loc.tutorialIrrigationImageTitle,
        "type": "image",
        "category": "farming",
        "imageUrl":
        "https://www.researchgate.net/publication/338053803/figure/fig1/AS:835245607219200@1575294216262/Drip-irrigation-vs-sprinkler-irrigation.png",
        "icon": Icons.image
      },
    ];
  }

  void _searchTutorials(String query, List<Map<String, dynamic>> source) {
    final results = source.where((tutorial) {
      final title = tutorial["title"].toLowerCase();
      final content = tutorial["content"]?.toLowerCase() ?? "";
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery) || content.contains(searchQuery);
    }).toList();

    setState(() {
      filteredTutorials = results;
    });
  }

  List<Map<String, dynamic>> _getFilteredByCategory(
      String category,
      List<Map<String, dynamic>> source) {
    if (category == "all") return source;
    return source.where((tutorial) => tutorial["category"] == category).toList();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.linkError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final allTutorials = _buildTutorials(loc);

    if (filteredTutorials.isEmpty && searchController.text.isEmpty) {
      filteredTutorials = allTutorials;
    }

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(loc.farmersGuideTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: loc.allGuides, icon: const Icon(Icons.all_inclusive)),
            Tab(text: loc.appHelp, icon: const Icon(Icons.smartphone)),
            Tab(text: loc.farmingTips, icon: const Icon(Icons.agriculture)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) =>
                  _searchTutorials(value, allTutorials),
              decoration: InputDecoration(
                hintText: loc.searchTutorialHint,
                prefixIcon:
                const Icon(Icons.search, color: Colors.green),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _searchTutorials("", allTutorials);
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTutorialList(
                    _getFilteredByCategory("all", filteredTutorials)),
                _buildTutorialList(
                    _getFilteredByCategory("app", filteredTutorials)),
                _buildTutorialList(
                    _getFilteredByCategory("farming", filteredTutorials)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialList(List<Map<String, dynamic>> tutorials) {
    final loc = AppLocalizations.of(context)!;

    if (tutorials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(loc.noTutorialsFound,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(loc.tryDifferentSearch,
                style:
                TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        return _buildTutorialCard(tutorials[index]);
      },
    );
  }

  Widget _buildTutorialCard(Map<String, dynamic> tutorial) {

    switch (tutorial["type"]) {

      case "video":
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          color: Colors.red.shade50,
          child: ListTile(
            leading: const Icon(Icons.play_circle, color: Colors.red),
            title: Text(tutorial["title"]),
            subtitle: Text(AppLocalizations.of(context)!.tapToWatchVideo),
            onTap: () => _launchURL(tutorial["url"]),
          ),
        );

      case "image":
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                tutorial["imageUrl"],
                errorBuilder: (context, error, stackTrace) =>
                const SizedBox(height: 200, child: Icon(Icons.image_not_supported)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(tutorial["title"]),
              ),
            ],
          ),
        );

      default:
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tutorial["title"],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (tutorial["content"] != null)
                  MarkdownBody(data: tutorial["content"]),
              ],
            ),
          ),
        );
    }
  }
}