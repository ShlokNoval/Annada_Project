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
import 'dart:async';
import 'auth_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> weatherFuture;
  late Future<List<Map<String, dynamic>>> newsFuture;

  String _userName = "";
  String _phoneNumber = "";
  String? _profilePhoto;
  bool _showWelcome = false;
  bool _showWeatherUpdated = false;
  bool _showNewsUpdated = false;

  final PageController _newsPageController = PageController();
  int _currentNewsIndex = 0;

  @override
  void initState() {
    super.initState();

    weatherFuture = Future.value({
      "location": "Loading...",
      "temp": "--",
      "desc": "Fetching weather..."
    });

    newsFuture = _getNews();

    _initLocationAndWeather();
    _loadProfileData();
    _startNewsAutoSlide();
  }

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

  Timer? _newsTimer;

  void _startNewsAutoSlide() {
    _newsTimer?.cancel();
    _newsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      newsFuture.then((articles) {
        if (!mounted || articles.isEmpty) return;
        setState(() {
          _currentNewsIndex = (_currentNewsIndex + 1) % articles.length;
        });
        _newsPageController.animateToPage(
          _currentNewsIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _newsTimer?.cancel();
    _newsPageController.dispose();
    super.dispose();
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

  Future<void> _refreshWeather() async {
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
      _showWeatherUpdated = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _showWeatherUpdated = false);
  }

  Future<void> _refreshNews() async {
    setState(() {
      newsFuture = _getNews();
      _showNewsUpdated = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _showNewsUpdated = false);
  }

  // ─── UPDATED: 5-Day Forecast Bottom Sheet ───────────────────────────────────
  Future<void> _showForecast() async {
    // Show the sheet immediately with a loading state
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ForecastSheet(
        forecastFuture: WeatherService().fetchDailyForecast(),
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(

      backgroundColor: Colors.green.shade50,


      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome banner ──────────────────────────────────────────
              if (_showWelcome)
                Dismissible(
                  key: const Key('welcome_banner'),
                  direction: DismissDirection.up,
                  onDismissed: (_) => _dismissWelcome(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Welcome, $_userName!",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _dismissWelcome,
                          child:
                          const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),



// 📰 News AFTER Weather
              FutureBuilder<List<Map<String, dynamic>>>(
                future: newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildNewsLoading();
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  } else {
                    return _buildNewsCarousel(snapshot.data!);
                  }
                },
              ),
              const SizedBox(height: 16),
              // 🌦 Weather FIRST
              FutureBuilder<Map<String, dynamic>>(
                future: weatherFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GestureDetector(
                      onTap: _showForecast,
                      child: _buildWeatherBox(
                          "Fetching location...", "Loading...", "Please wait..."),
                    );
                  } else if (snapshot.hasError) {
                    return GestureDetector(
                      onTap: _showForecast,
                      child: _buildWeatherBox(
                          "Error", "❌", "Could not load weather"),
                    );
                  } else {
                    var data = snapshot.data ?? {};
                    return GestureDetector(
                      onTap: _showForecast,
                      child: _buildWeatherBox(
                          data["location"], data["temp"], data["desc"]),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // ── Feature grid ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 28, bottom: 12),
                child: Center(
                  child: Text(
                    "Features",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFeatureBox(
                    "Fertilizer Calculator",
                    FontAwesomeIcons.seedling,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const FertilizerCalculatorPage())),
                  ),
                  _buildFeatureBox(
                    "Crop Detection",
                    FontAwesomeIcons.camera,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ImageDetectionPage())),
                  ),

                  _buildFeatureBox(
                    "Tutorial",
                    FontAwesomeIcons.bookOpen,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TutorialPage())),
                  ),
                  _buildFeatureBox(
                    "Yojna",
                    FontAwesomeIcons.handshake,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => YojnaPage())),
                  ),

                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────────────────────


  Widget _buildWeatherBox(
      String location, String temperature, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade900.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, size: 48, color: Colors.yellowAccent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(temperature,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    Text(description,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh,
                          color: Colors.white, size: 20),
                      onPressed: _refreshWeather,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    opacity: _showWeatherUpdated ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: const Text("Updated",
                        style:
                        TextStyle(color: Colors.white70, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Hint to tap for forecast ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              const Text(
                "Tap for 5-day forecast",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
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
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _newsPageController,
              onPageChanged: (index) =>
                  setState(() => _currentNewsIndex = index),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return GestureDetector(
                  onTap: () => _launchUrl(article['url']),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(article['imageUrl'], fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Text(
                          article['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Colors.white, size: 20),
                    onPressed: _refreshNews,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedOpacity(
                  opacity: _showNewsUpdated ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: const Text("Updated",
                      style:
                      TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBox(String title, IconData icon,
      {required VoidCallback onTap}) {
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


// ─── Forecast Bottom Sheet Widget ────────────────────────────────────────────

class _ForecastSheet extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> forecastFuture;

  const _ForecastSheet({required this.forecastFuture});

  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  static const List<String> _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _dayLabel(DateTime dt) {
    return "${_weekdays[dt.weekday - 1]}, ${dt.day} ${_months[dt.month]}";
  }

  /// Maps OpenWeatherMap icon codes to Flutter Material icons
  IconData _iconForCode(String code) {
    if (code.startsWith('01')) return Icons.wb_sunny;
    if (code.startsWith('02') || code.startsWith('03') || code.startsWith('04')) {
      return Icons.cloud;
    }
    if (code.startsWith('09') || code.startsWith('10')) return Icons.water_drop;
    if (code.startsWith('11')) return Icons.thunderstorm;
    if (code.startsWith('13')) return Icons.ac_unit;
    if (code.startsWith('50')) return Icons.foggy;
    return Icons.wb_cloudy;
  }

  Color _iconColor(String code) {
    if (code.startsWith('01')) return Colors.amber;
    if (code.startsWith('02') || code.startsWith('03') || code.startsWith('04')) {
      return Colors.blueGrey;
    }
    if (code.startsWith('09') || code.startsWith('10')) return Colors.blue;
    if (code.startsWith('11')) return Colors.deepPurple;
    if (code.startsWith('13')) return Colors.lightBlue.shade200;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle ────────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month,
                        color: Colors.green.shade700, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "5-Day Weather Forecast",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Annada ensures error-free weather forecasts for any location.",
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 12),

              const Divider(height: 1),

              // ── Forecast list ─────────────────────────────────────────
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: forecastFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.green),
                            SizedBox(height: 12),
                            Text("Fetching forecast...",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "Forecast unavailable.\nCheck internet or location access.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    final days = snapshot.data!;

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: days.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.grey.shade100, height: 1),
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final DateTime date = day['date'] as DateTime;
                        final double minT = day['minTemp'] as double;
                        final double maxT = day['maxTemp'] as double;
                        final String desc = day['description'] as String;
                        final String icon = day['icon'] as String;
                        final int rain = day['rainChance'] as int;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              // Day label
                              SizedBox(
                                width: 90,
                                child: Text(
                                  _dayLabel(date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                              // Weather icon
                              Icon(
                                _iconForCode(icon),
                                color: _iconColor(icon),
                                size: 28,
                              ),

                              const SizedBox(width: 10),

                              // Description + rain chance
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _capitalize(desc),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    if (rain > 10)
                                      Row(
                                        children: [
                                          Icon(Icons.water_drop,
                                              size: 11,
                                              color: Colors.blue.shade300),
                                          const SizedBox(width: 2),
                                          Text(
                                            "$rain%",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                              // Min / Max temps
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${maxT.toStringAsFixed(0)}°",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${minT.toStringAsFixed(0)}°",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
