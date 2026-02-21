import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Add this import

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allTutorials = [];
  List<Map<String, dynamic>> filteredTutorials = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeTutorials();
    filteredTutorials = allTutorials;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeTutorials() {
    allTutorials = [
      // App Usage Guides
      {
        "title": "📱 Getting Started with Annada App",
        "type": "app_guide",
        "category": "app",
        "content": "Welcome to Annada! Here's how to get started:\n\n1. **Profile Setup**: Tap the profile icon in the top-right corner to add your details and photo\n2. **Weather Updates**: Check real-time weather on your dashboard\n3. **Feature Access**: Use the grid to access all farming tools\n4. **Stay Updated**: Read farming news that auto-updates on your homepage",
        "icon": Icons.smartphone
      },
      {
        "title": "🌾 How to Use Crop Detection Feature",
        "type": "app_guide",
        "category": "app",
        "content": "Analyze your crops with AI:\n\n1. **Open Crop Detection**: Tap the camera icon on homepage\n2. **Take/Upload Photo**: Use camera or gallery to select crop image\n3. **Enter Crop Type**: Type your crop name (e.g., tomato, wheat)\n4. **Get Analysis**: Tap 'Analyze Now' for detailed health report\n5. **Follow Suggestions**: Implement the recommended solutions",
        "icon": Icons.camera_alt
      },
      {
        "title": "🧮 Using Fertilizer Calculator",
        "type": "app_guide",
        "category": "app",
        "content": "Calculate precise fertilizer needs:\n\n1. **Select Crop**: Choose your crop from the dropdown\n2. **Enter Area**: Input your field size in acres\n3. **Soil Type**: Select your soil type\n4. **Get Recommendations**: View NPK requirements and costs\n5. **Save Results**: Screenshot or note down for future reference",
        "icon": Icons.calculate
      },
      {
        "title": "🤖 Chat with Annada Assistant",
        "type": "app_guide",
        "category": "app",
        "content": "Get instant farming advice:\n\n1. **Access Assistant**: Tap the robot icon on homepage\n2. **Ask Questions**: Type any farming-related question\n3. **Get Responses**: Receive expert advice instantly\n4. **Follow Up**: Ask more specific questions based on responses\n5. **Save Important Tips**: Take screenshots of useful advice",
        "icon": Icons.smart_toy
      },
      {
        "title": "🗺️ Finding Nearby Markets",
        "type": "app_guide",
        "category": "app",
        "content": "Connect with local markets:\n\n1. **Open Market Finder**: Tap 'Market Connectivity'\n2. **Allow Location**: Grant location permission for accurate results\n3. **Browse Markets**: View nearby agricultural markets\n4. **Check Details**: See contact info and market timings\n5. **Plan Visits**: Use integrated maps for directions",
        "icon": Icons.location_on
      },
      // Comprehensive Farming Guides
      {
        "title": "🌱 Complete Guide to Organic Farming",
        "type": "text",
        "category": "farming",
        "content": "**What is Organic Farming?**\nOrganic farming uses natural methods without synthetic chemicals, GMOs, or artificial fertilizers.\n\n**Key Principles:**\n• Soil health through composting and crop rotation\n• Natural pest control using beneficial insects\n• Water conservation techniques\n• Biodiversity preservation\n\n**Benefits:**\n• Higher market prices (20-40% premium)\n• Improved soil fertility over time\n• Reduced health risks for farmers\n• Environmental sustainability\n\n**Getting Started:**\n1. Soil testing and analysis\n2. Transition period (2-3 years)\n3. Organic certification process\n4. Market research and buyer connections",
        "icon": Icons.eco
      },
      {
        "title": "💧 Smart Irrigation Techniques",
        "type": "text",
        "category": "farming",
        "content": "**Drip Irrigation:**\n• 90% water efficiency\n• Direct root zone watering\n• Reduces weed growth\n• Cost: ₹25,000-50,000 per acre\n\n**Sprinkler Systems:**\n• Good for large fields\n• Uniform water distribution\n• Lower initial cost\n• Suitable for most crops\n\n**Rainwater Harvesting:**\n• Collect monsoon water\n• Reduce groundwater dependency\n• Government subsidies available\n• ROI within 2-3 years\n\n**Smart Scheduling:**\n• Use soil moisture sensors\n• Check weather forecasts\n• Water early morning or evening\n• Adjust based on crop growth stage",
        "icon": Icons.water_drop
      },
      {
        "title": "🐛 Integrated Pest Management (IPM)",
        "type": "text",
        "category": "farming",
        "content": "**Prevention First:**\n• Crop rotation breaks pest cycles\n• Resistant varieties reduce pesticide use\n• Proper field sanitation\n• Balanced nutrition prevents stress\n\n**Natural Controls:**\n• Beneficial insects (ladybugs, spiders)\n• Neem oil spray for soft-bodied insects\n• Pheromone traps for moths\n• Bird perches for natural predation\n\n**Biological Controls:**\n• Bacillus thuringiensis (Bt) for caterpillars\n• Trichoderma for soil diseases\n• Parasitic wasps for aphids\n\n**Chemical Controls (Last Resort):**\n• Use only when threshold levels reached\n• Rotate different chemical groups\n• Follow safety guidelines strictly\n• Respect pre-harvest intervals",
        "icon": Icons.bug_report
      },
      {
        "title": "🌾 Crop Rotation Strategies",
        "type": "text",
        "category": "farming",
        "content": "**4-Year Rotation Plan:**\n\n**Year 1: Nitrogen-fixing crops**\n• Legumes (beans, peas, lentils)\n• Add nitrogen to soil naturally\n• Break disease cycles\n\n**Year 2: Leafy crops**\n• Utilize nitrogen from previous year\n• Spinach, lettuce, cabbage\n• Different root depths\n\n**Year 3: Root crops**\n• Carrots, potatoes, radishes\n• Break up soil compaction\n• Different nutrient requirements\n\n**Year 4: Grains/Cereals**\n• Wheat, rice, corn\n• Complete the cycle\n• Prepare for next rotation\n\n**Benefits:**\n• 25-30% yield increase\n• Reduced pest pressure\n• Improved soil structure\n• Lower input costs",
        "icon": Icons.refresh
      },
      {
        "title": "🧪 Soil Health Management",
        "type": "text",
        "category": "farming",
        "content": "**Soil Testing (Annual):**\n• pH levels (6.0-7.5 ideal for most crops)\n• NPK availability\n• Organic matter content\n• Micronutrient status\n\n**Improving Soil Health:**\n• Add 2-3 tons compost per acre annually\n• Use cover crops during fallow periods\n• Minimize tillage to preserve structure\n• Apply lime if pH is below 6.0\n\n**Organic Matter Boost:**\n• Vermicomposting\n• Green manuring\n• Farmyard manure\n• Crop residue incorporation\n\n**Signs of Healthy Soil:**\n• Earthworms present\n• Good water infiltration\n• Crumbly structure\n• Rich, dark color\n• Sweet, earthy smell",
        "icon": Icons.terrain
      },
      {
        "title": "📊 Farm Financial Management",
        "type": "text",
        "category": "farming",
        "content": "**Record Keeping:**\n• Daily expense tracking\n• Input costs (seeds, fertilizers, labor)\n• Revenue from sales\n• Profit/loss analysis per crop\n\n**Cost Reduction Strategies:**\n• Bulk purchasing of inputs\n• Cooperative farming\n• Government scheme utilization\n• Energy-efficient equipment\n\n**Revenue Optimization:**\n• Direct marketing to consumers\n• Value addition (processing)\n• Contract farming\n• Export opportunities\n\n**Financial Planning:**\n• Crop insurance (PMFBY)\n• Emergency fund (20% of annual income)\n• Equipment depreciation calculation\n• Tax planning and compliance",
        "icon": Icons.account_balance
      },
      {
        "title": "🚜 Farm Mechanization Guide",
        "type": "text",
        "category": "farming",
        "content": "**Essential Equipment by Farm Size:**\n\n**Small Farms (1-5 acres):**\n• Power tiller (₹80,000-1,20,000)\n• Knapsack sprayer\n• Manual tools\n\n**Medium Farms (5-20 acres):**\n• Compact tractor 25-35 HP\n• Rotavator\n• Seed drill\n• Harvester (shared/custom)\n\n**Large Farms (20+ acres):**\n• Heavy tractor 50+ HP\n• Combine harvester\n• Precision planters\n• GPS-guided equipment\n\n**Maintenance Tips:**\n• Daily cleaning after use\n• Regular oil changes\n• Proper storage\n• Annual servicing\n• Operator training",
        "icon": Icons.construction
      },
      {
        "title": "🌤️ Weather-Based Farming",
        "type": "text",
        "category": "farming",
        "content": "**Seasonal Planning:**\n\n**Kharif Season (June-October):**\n• Monsoon-dependent crops\n• Rice, cotton, sugarcane\n• Drainage systems important\n\n**Rabi Season (November-April):**\n• Winter crops\n• Wheat, mustard, peas\n• Irrigation planning crucial\n\n**Zaid Season (April-June):**\n• Summer crops\n• Watermelon, fodder crops\n• High water requirement\n\n**Weather Monitoring:**\n• Use weather apps daily\n• Understand IMD forecasts\n• Plan operations accordingly\n• Have contingency plans\n\n**Climate Adaptation:**\n• Drought-resistant varieties\n• Water storage systems\n• Crop diversification\n• Insurance coverage",
        "icon": Icons.wb_sunny
      },
      // Video Tutorials
      {
        "title": "📽️ Modern Wheat Cultivation Techniques",
        "type": "video",
        "category": "farming",
        "url": "https://www.youtube.com/watch?v=MyfHCt7DDOg",
        "icon": Icons.play_circle
      },
      {
        "title": "📽️ Tomato Plant Care and Pruning",
        "type": "video",
        "category": "farming",
        "url": "https://www.youtube.com/watch?v=R65zFZ9-nPU",
        "icon": Icons.play_circle
      },
      {
        "title": "📽️ Understanding Crop Rotation Benefits",
        "type": "video",
        "category": "farming",
        "url": "https://www.youtube.com/watch?v=VcnzXJZxajQ",
        "icon": Icons.play_circle
      },
      // Visual Guides
      {
        "title": "📷 Pest Identification Chart",
        "type": "image",
        "category": "farming",
        "imageUrl": "https://cdn.agroop.net/wp-content/uploads/2020/09/insectos-agricultura.jpg",
        "icon": Icons.image
      },
      {
        "title": "📷 Soil Types and Characteristics",
        "type": "image",
        "category": "farming",
        "imageUrl": "https://www.soils4teachers.org/files/s4t/images/SoilTexturesChart.jpg",
        "icon": Icons.image
      },
      {
        "title": "📷 Irrigation Systems Comparison",
        "type": "image",
        "category": "farming",
        "imageUrl": "https://www.researchgate.net/publication/338053803/figure/fig1/AS:835245607219200@1575294216262/Drip-irrigation-vs-sprinkler-irrigation.png",
        "icon": Icons.image
      },
    ];
  }

  void _searchTutorials(String query) {
    final results = allTutorials.where((tutorial) {
      final title = tutorial["title"].toLowerCase();
      final content = tutorial["content"]?.toLowerCase() ?? "";
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery) || content.contains(searchQuery);
    }).toList();

    setState(() {
      filteredTutorials = results;
    });
  }

  List<Map<String, dynamic>> _getFilteredByCategory(String category) {
    if (category == "all") return filteredTutorials;
    return filteredTutorials.where((tutorial) => tutorial["category"] == category).toList();
  }

  Widget _buildTutorialCard(Map<String, dynamic> tutorial) {
    switch (tutorial["type"]) {
      case "app_guide":
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(tutorial["icon"], color: Colors.blue.shade700, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tutorial["title"],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // UPDATED: Using MarkdownBody instead of Text
                  MarkdownBody(
                    data: tutorial["content"],
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 14, height: 1.5),
                      listBullet: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case "text":
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(tutorial["icon"], color: Colors.green.shade700, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tutorial["title"],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // UPDATED: Using MarkdownBody instead of Text
                MarkdownBody(
                  data: tutorial["content"],
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 14, height: 1.5),
                    listBullet: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        );
      case "video":
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          color: Colors.red.shade50,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_circle, size: 32, color: Colors.red),
            ),
            title: Text(
              tutorial["title"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Tap to watch video tutorial"),
            onTap: () => _launchURL(tutorial["url"]),
          ),
        );
      case "image":
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  tutorial["imageUrl"],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(tutorial["icon"], color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tutorial["title"],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch link")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text("Farmer's Guide", style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "All Guides", icon: Icon(Icons.all_inclusive, size: 20)),
            Tab(text: "App Help", icon: Icon(Icons.smartphone, size: 20)),
            Tab(text: "Farming Tips", icon: Icon(Icons.agriculture, size: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: _searchTutorials,
              decoration: InputDecoration(
                hintText: "Search farming guides, app help, tips...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _searchTutorials("");
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.green.shade400, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Guides
                _buildTutorialList(_getFilteredByCategory("all")),
                // App Guides
                _buildTutorialList(_getFilteredByCategory("app")),
                // Farming Guides
                _buildTutorialList(_getFilteredByCategory("farming")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialList(List<Map<String, dynamic>> tutorials) {
    if (tutorials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No tutorials found",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "Try different search terms",
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        return _buildTutorialCard(tutorials[index]);
      },
    );
  }
}