import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class YojnaPage extends StatelessWidget {
  const YojnaPage({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final List<Map<String, String>> schemes = [
      {
        "name": loc.pmKisanName,
        "description": loc.pmKisanDesc,
        "url": "https://pmkisan.gov.in/",
        "logo": "assets/pm-kisan.png",
      },
      {
        "name": loc.pmfbName,
        "description": loc.pmfbDesc,
        "url": "https://pmfby.gov.in/",
        "logo": "assets/pmfby.png",
      },
      {
        "name": loc.kccName,
        "description": loc.kccDesc,
        "url": "https://www.pmkisan.gov.in/",
        "logo": "assets/kcc.png",
      },
      {
        "name": loc.soilHealthName,
        "description": loc.soilHealthDesc,
        "url": "https://soilhealth.dac.gov.in/",
        "logo": "assets/soil-health.png",
      },
      {
        "name": loc.pmksyName,
        "description": loc.pmksyDesc,
        "url": "https://pmksy.gov.in/",
        "logo": "assets/pmsky.png",
      },
      {
        "name": loc.enamName,
        "description": loc.enamDesc,
        "url": "https://enam.gov.in/",
        "logo": "assets/enam.png",
      },
      {
        "name": loc.rkvyName,
        "description": loc.rkvyDesc,
        "url": "https://rkvy.nic.in/",
        "logo": "assets/rkvy.png",
      },
      {
        "name": loc.pkvyName,
        "description": loc.pkvyDesc,
        "url": "https://pgsindia-ncof.gov.in/",
        "logo": "assets/pkvy.png",
      },
      {
        "name": loc.dedsName,
        "description": loc.dedsDesc,
        "url": "https://nabard.org/",
        "logo": "assets/deds.png",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.governmentSchemesTitle),
        backgroundColor: Colors.green.shade700,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: schemes.length,
        itemBuilder: (context, index) {
          final scheme = schemes[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          scheme['logo']!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          scheme['name']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scheme['description']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchURL(scheme['url']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.open_in_new,
                          color: Colors.white),
                      label: Text(
                        loc.applyNow,
                        style:
                        const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}