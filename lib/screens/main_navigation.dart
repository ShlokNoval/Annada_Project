import 'package:flutter/material.dart';
import 'home_page.dart';
import 'NearnessOfMarket.dart';
import 'profile_page.dart';
import 'gemini_page.dart';
import 'login_page.dart';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'community_feed_page.dart';


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
  CommunityFeedPage(), // 🔥 REAL GLOBAL CHAT
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
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
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

      body: Stack(
        children: [

          // Main Page
          _pages[_selectedIndex],

          // 🔥 Draggable Gemini Button
          DraggableFloatingButton(),
        ],
      ),




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

class DraggableFloatingButton extends StatefulWidget {
  const DraggableFloatingButton({super.key});

  @override
  State<DraggableFloatingButton> createState() =>
      _DraggableFloatingButtonState();
}

class _DraggableFloatingButtonState
    extends State<DraggableFloatingButton> {

  double top = 500;
  double left = 300;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Draggable(
        feedback: _buildButton(context),
        childWhenDragging: const SizedBox(),
        onDragEnd: (details) {
          setState(() {
            top = details.offset.dy;
            left = details.offset.dx;
          });
        },
        child: _buildButton(context),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GeminiPage()),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/gemini.png',
          ),
        ),
      ),
    );
  }
}