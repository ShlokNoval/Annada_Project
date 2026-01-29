import 'package:annadaauth1/screens/tutorial.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/weather_service.dart';
import '../screens/gemini_page.dart';
import '../screens/Fertilizer_calculator.dart';
import '../screens/profile_page.dart';
import '../screens/yojna_page.dart';
import '../screens/notification_service.dart';
import '../screens/image_detection.dart';
import '../screens/nearnessofmarket.dart';
import '../screens/news_service.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> weatherFuture;
  late Future<List<Map<String, dynamic>>> newsFuture;

  String _userName = "";
  String _phoneNumber = "";
  String? _profilePhoto;
  bool _showWelcome = false;

  PageController _newsPageController = PageController();
  int _currentNewsIndex = 0;

  @override
  void initState() {
    super.initState();
    _initLocationAndWeather(); // ✅ ONLY weather initializer
    newsFuture = _getNews();
    _loadProfileData();
    _startNewsAutoSlide();
  }

  @override
  void dispose() {
    _newsPageController.dispose();
    super.dispose();
  }


  /// ✅ NEW – handles permission + weather safely
  Future<void> _initLocationAndWeather() async {
    final weatherService = WeatherService();
    final hasPermission = await weatherService.ensureLocationPermission();

    setState(() {
      weatherFuture = hasPermission
          ? _getWeather()
          : Future.value({
        "location": "Permission Required",
        "temp": "❌",
        "desc": "Enable location to get weather info",
      });
    });
  }

  Future<List<Map<String, dynamic>>> _getNews() async {
    final newsService = NewsService();
    return await newsService.fetchFarmingNews();
  }

  Future<Map<String, dynamic>> _getWeather() async {
    final weatherService = WeatherService();
    try {
      final weatherData = await weatherService.fetchWeather();

      if (weatherData.containsKey("main")) {
        double temp =
            double.tryParse(weatherData['main']['temp'].toString()) ?? 0;

        if (temp > 35) {
          NotificationService.showWeatherAlert(
            "☀️ High Temperature Alert!",
            "It's too hot today: ${temp.toStringAsFixed(1)}°C. Stay hydrated!",
          );
        } else if (temp < 10) {
          NotificationService.showWeatherAlert(
            "❄️ Low Temperature Alert!",
            "It's very cold: ${temp.toStringAsFixed(1)}°C. Stay warm!",
          );
        }
      }

      return {
        "temp": "${weatherData['main']['temp']}°C",
        "desc": weatherData['weather'][0]['description'].toString(),
        "location": weatherData['name'].toString(),
      };
    } catch (e) {
      return {
        "temp": "❌",
        "desc": "Location/Weather issue",
        "location": "Unavailable",
      };
    }
  }

  void _startNewsAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      newsFuture.then((articles) {
        if (articles.isNotEmpty) {
          setState(() {
            _currentNewsIndex = (_currentNewsIndex + 1) % articles.length;
          });
          _newsPageController.animateToPage(
            _currentNewsIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
      _startNewsAutoSlide();
    });
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "";
      _phoneNumber = prefs.getString('phoneNumber') ?? "";
      _profilePhoto = prefs.getString('profilePhoto');
      _showWelcome = _userName.isNotEmpty;
    });
  }

  void _dismissWelcome() {
    setState(() => _showWelcome = false);
  }

  Future<void> _launchUrl(String url) async {
    if (url != '#') {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
  Future<void> _refreshWeatherAndNews() async {
    final weatherService = WeatherService();
    final hasPermission = await weatherService.ensureLocationPermission();

    setState(() {
      weatherFuture = hasPermission
          ? _getWeather()
          : Future.value({
        "location": "Permission Required",
        "temp": "❌",
        "desc": "Enable location to get weather info",
      });

      newsFuture = _getNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 2,
        title: const Text(
          "Your Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // 🔽 Profile
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              _loadProfileData();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                _profilePhoto != null ? NetworkImage(_profilePhoto!) : null,
                child: _profilePhoto == null
                    ? const Icon(Icons.person, size: 30, color: Colors.green)
                    : null,
              ),
            ),
          ),

          // 🔽 Logout menu

        ],
      ),

      // 🔻 BODY REMAINS 100% UNCHANGED BELOW
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            if (_showWelcome)
              Dismissible(
                key: const Key('welcome_banner'),
                direction: DismissDirection.up,
                onDismissed: (_) => _dismissWelcome(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade800.withOpacity(0.4),
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.eco, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Welcome, $_userName!",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _dismissWelcome,
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // 🔻 EVERYTHING ELSE BELOW IS UNCHANGED
            // (news, weather, features, etc.)
            // ⬇️ your existing code continues as-is


            // News Carousel
            FutureBuilder<List<Map<String, dynamic>>>(
              future: newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildNewsLoading();
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                } else {
                  return _buildNewsCarousel(snapshot.data!);
                }
              },
            ),

            const SizedBox(height: 16),

            FutureBuilder<Map<String, dynamic>>(
              future: weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildWeatherBox(
                      "Fetching location...", "Loading...", "Please wait...");
                } else if (snapshot.hasError) {
                  return _buildWeatherBox(
                      "Error", "❌", "Could not load weather");
                } else {
                  var data = snapshot.data ?? {};
                  return _buildWeatherBox(
                      data["location"], data["temp"], data["desc"]);
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final weatherService = WeatherService();
                final hasPermission = await weatherService.ensureLocationPermission();

                setState(() {
                  weatherFuture = hasPermission
                      ? _getWeather()
                      : Future.value({
                    "location": "Permission Required",
                    "temp": "❌",
                    "desc": "Enable location to get weather info",
                  });

                  newsFuture = _getNews();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh Weather & News"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
            ),

            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Features",
                style: theme.textTheme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 1,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFeatureBox(
                    "Fertilizer Calculator",
                    FontAwesomeIcons.seedling,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const FertilizerCalculatorPage()));
                    },
                  ),
                  _buildFeatureBox(
                    "Crop Detection",
                    FontAwesomeIcons.camera,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ImageDetectionPage()));
                    },
                  ),
                  _buildFeatureBox(
                    "Market Connectivity",
                    FontAwesomeIcons.mapLocationDot,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NearnessOfMarketPage()));
                    },
                  ),
                  _buildFeatureBox(
                    "Tutorial",
                    FontAwesomeIcons.bookOpen,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TutorialPage()));
                    },
                  ),
                  _buildFeatureBox(
                    "Yojna",
                    FontAwesomeIcons.handshake,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => YojnaPage()));
                    },
                  ),
                  _buildFeatureBox(
                    "Annada Assistant",
                    FontAwesomeIcons.robot,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GeminiPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsLoading() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }

  Widget _buildNewsCarousel(List<Map<String, dynamic>> articles) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: PageView.builder(
        controller: _newsPageController,
        onPageChanged: (index) {
          setState(() {
            _currentNewsIndex = index;
          });
        },
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () => _launchUrl(article['url']),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(article['imageUrl']),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {},
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.article, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          "Farming News",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherBox(String location, String temperature, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade900.withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, size: 60, color: Colors.yellowAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 3, color: Colors.black38)],
                  ),
                ),
                Text(
                  temperature,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 5, color: Colors.black45)],
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBox(String title, IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.green.shade100,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.green.shade700),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
