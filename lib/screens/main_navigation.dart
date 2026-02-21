import 'package:flutter/material.dart';
import 'home_page.dart';
import 'NearnessOfMarket.dart';
import 'profile_page.dart';
import 'gemini_page.dart';
import 'login_page.dart';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  String _userName = "";
  String _profilePhoto = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "User";
      _profilePhoto = prefs.getString('profilePhoto') ?? "";
    });
  }

  final List<Widget> _pages = const [
    HomePage(),
    NearnessOfMarketPage(),
    Center(
      child: Text(
        "Global Community\nComing Soon",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    ),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 🔥 Drawer
  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [

          // 🔥 Custom Header with Background Image
          Container(
            height: 190,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/profile_bg.webp'), // 👈 your custom bg
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4), // dark overlay
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: _profilePhoto.isNotEmpty
                        ? NetworkImage(_profilePhoto)
                        : null,
                    child: _profilePhoto.isEmpty
                        ? const Icon(Icons.person,
                        size: 30, color: Colors.green)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          _drawerItem('assets/home.png', "Home", 0),
          _drawerItem('assets/market.png', "Market", 1),
          _drawerItem('assets/community.png', "Community", 2),
          _drawerItem('assets/profile.png', "Profile", 3),

          const Spacer(),
          const Divider(),

          Padding(
            padding: const EdgeInsets.only(bottom: 35), // 👈 adjust 30–50 if needed
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async {
                Navigator.pop(context);

                await AuthService().signOut();

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );

  }

  Widget _drawerItem(String assetPath, String title, int index) {
    return ListTile(
      leading: Image.asset(
        assetPath,
        width: 22,
        height: 22,
      ),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        title: const Text(
          "Annada",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              'assets/Annadalogocrop.png',
              height: 40,
            ),
          ),
        ],
      ),

      body: _pages[_selectedIndex],

      // 🤖 Floating Gemini Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade100,
        child: Image.asset(
          'assets/gemini.png',
          width: 32,
          height: 32,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GeminiPage()),
          );
        },
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,

      // 🔻 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/home.png', width: 24),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/market.png', width: 24),
            label: "Market",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/community.png', width: 24),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/profile.png', width: 24),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}