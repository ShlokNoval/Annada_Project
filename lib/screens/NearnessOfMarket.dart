import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:annadaauth1/screens/map1.dart';
import 'package:annadaauth1/screens/map2.dart';
import 'package:annadaauth1/screens/map3.dart';

class NearnessOfMarketPage extends StatefulWidget {
  const NearnessOfMarketPage({super.key});

  @override
  State<NearnessOfMarketPage> createState() =>
      _NearnessOfMarketPageState();
}

class _NearnessOfMarketPageState
    extends State<NearnessOfMarketPage> {

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.nearnessOfMarket),
        backgroundColor: Colors.green.shade700,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ───── Nearby Markets ─────
              Text(
                loc.nearbyMarkets,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: [

                    MarketCard(
                      marketName: loc.locateFertilizerShops,
                      onTap: () =>
                          _navigateToMap(context, const Map1Page()),
                    ),

                    MarketCard(
                      marketName: loc.searchNearbyMarket,
                      onTap: () =>
                          _navigateToMap(context, const Map2Page()),
                    ),

                    MarketCard(
                      marketName: loc.localRecyclingAgencies,
                      onTap: () =>
                          _navigateToMap(context, const Map3Page()),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMap(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class MarketCard extends StatelessWidget {
  final String marketName;
  final VoidCallback onTap;

  const MarketCard({
    super.key,
    required this.marketName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(
                Icons.store,
                size: 40,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  marketName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}