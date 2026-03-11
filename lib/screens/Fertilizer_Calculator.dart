import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FertilizerCalculatorPage extends StatefulWidget {
  const FertilizerCalculatorPage({super.key});

  @override
  _FertilizerCalculatorPageState createState() =>
      _FertilizerCalculatorPageState();
}

class _FertilizerCalculatorPageState
    extends State<FertilizerCalculatorPage> {

  String unit = "acre";
  String? selectedCrop, selectedSoil, selectedGrowthStage;

  final TextEditingController areaController = TextEditingController();
  double nitrogen = 0, phosphorus = 0, potassium = 0;
  String recommendedFertilizer = "";

  // 🔥 Dynamic Localized Lists
  List<String> _getCrops(AppLocalizations loc) => [
    loc.crop_wheat,
    loc.crop_rice,
    loc.crop_corn,
    loc.crop_soybean,
    loc.crop_tomato,
    loc.crop_potato,
    loc.crop_carrot,
    loc.crop_onion,
    loc.crop_cabbage,
    loc.crop_chili,
    loc.crop_banana,
    loc.crop_apple,
  ];

  List<String> _getSoils(AppLocalizations loc) => [
    loc.soil_sandy,
    loc.soil_clay,
    loc.soil_loam,
    loc.soil_silty,
    loc.soil_peaty,
    loc.soil_chalky,
    loc.soil_saline,
    loc.soil_red,
    loc.soil_black,
  ];

  List<String> _getGrowthStages(AppLocalizations loc) => [
    loc.stage_seedling,
    loc.stage_vegetative,
    loc.stage_flowering,
    loc.stage_fruiting,
    loc.stage_maturity,
    loc.stage_harvesting,
  ];

  void calculateFertilizer() {
    final loc = AppLocalizations.of(context)!;

    double area = double.tryParse(areaController.text) ?? 0;

    if (unit == "hectare") {
      area *= 2.471;
    }

    nitrogen = area * 50;
    phosphorus = area * 30;
    potassium = area * 40;

    recommendFertilizer();
    setState(() {});
  }

  void recommendFertilizer() {
    final loc = AppLocalizations.of(context)!;
    recommendedFertilizer = "";

    if (nitrogen >= 100) {
      recommendedFertilizer +=
      "🟢 Urea (46% N): ${((nitrogen / 46) * 100).toStringAsFixed(2)} kg\n";
    }
    if (phosphorus >= 50) {
      recommendedFertilizer +=
      "🔵 DAP (46% P): ${((phosphorus / 46) * 100).toStringAsFixed(2)} kg\n";
    }
    if (potassium >= 40) {
      recommendedFertilizer +=
      "🟠 MOP (60% K): ${((potassium / 60) * 100).toStringAsFixed(2)} kg\n";
    }

    if (recommendedFertilizer.isEmpty) {
      recommendedFertilizer = "✅ ${loc.noFertilizerNeeded}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final crops = _getCrops(loc);
    final soils = _getSoils(loc);
    final stages = _getGrowthStages(loc);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.fertilizerCalculatorTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.yellow.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              _buildCard(
                title: loc.landArea,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: areaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: loc.enterArea,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: unit,
                      items: [
                        DropdownMenuItem<String>(
                          value: "acre",
                          child: Text(loc.acre),
                        ),
                        DropdownMenuItem<String>(
                          value: "hectare",
                          child: Text(loc.hectare),
                        ),
                      ],
                      onChanged: (newValue) {
                        setState(() {
                          unit = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              _buildCard(
                title: loc.selectCropSoil,
                child: Column(
                  children: [
                    _buildDropdown(loc.selectCrop, crops,
                            (value) => selectedCrop = value),
                    const SizedBox(height: 10),
                    _buildDropdown(loc.selectSoilType, soils,
                            (value) => selectedSoil = value),
                    const SizedBox(height: 10),
                    _buildDropdown(loc.growthStage, stages,
                            (value) => selectedGrowthStage = value),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
                onPressed: calculateFertilizer,
                child: Text(
                  loc.calculateFertilizer,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              if (nitrogen > 0)
                _buildCard(
                  title: loc.fertilizerRequirements,
                  bgColor: Colors.green.shade50,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text("🌱 ${loc.cropType}: $selectedCrop"),
                      Text("🌍 ${loc.soilType}: $selectedSoil"),
                      Text("📈 ${loc.growthStageLabel}: $selectedGrowthStage"),
                      const Divider(),
                      Text("💧 ${loc.nitrogenNeeded}: ${nitrogen.toStringAsFixed(2)} kg"),
                      Text("🌿 ${loc.phosphorusNeeded}: ${phosphorus.toStringAsFixed(2)} kg"),
                      Text("🟤 ${loc.potassiumNeeded}: ${potassium.toStringAsFixed(2)} kg"),
                      const Divider(),
                      Text("🛒 ${loc.recommendedFertilizers}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(recommendedFertilizer),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    Color? bgColor,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      color: bgColor ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label,
      List<String> items,
      Function(String?) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map<DropdownMenuItem<String>>(
            (String item) =>
            DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
      )
          .toList(),
      onChanged: (value) =>
          setState(() => onChanged(value)),
    );
  }
}