import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() async {
  final rng = Random(42);

  // Indian coastal cities with approximate coordinates
  final coastalCities = <Map<String, dynamic>>[
    {'name': 'Mumbai, Maharashtra', 'lat': 19.0760, 'lng': 72.8777},
    {'name': 'Chennai, Tamil Nadu', 'lat': 13.0827, 'lng': 80.2707},
    {'name': 'Kolkata, West Bengal', 'lat': 22.5726, 'lng': 88.3639},
    {'name': 'Visakhapatnam, Andhra Pradesh', 'lat': 17.6868, 'lng': 83.2185},
    {'name': 'Kochi, Kerala', 'lat': 9.9312, 'lng': 76.2673},
    {'name': 'Mangalore, Karnataka', 'lat': 12.9141, 'lng': 74.8560},
    {'name': 'Puri, Odisha', 'lat': 19.8135, 'lng': 85.8312},
    {'name': 'Paradip, Odisha', 'lat': 20.3167, 'lng': 86.6167},
    {'name': 'Digha, West Bengal', 'lat': 21.6277, 'lng': 87.5083},
    {'name': 'Puducherry', 'lat': 11.9416, 'lng': 79.8083},
    {'name': 'Kakinada, Andhra Pradesh', 'lat': 16.9891, 'lng': 82.2475},
    {'name': 'Thoothukudi, Tamil Nadu', 'lat': 8.7642, 'lng': 78.1348},
    {'name': 'Porbandar, Gujarat', 'lat': 21.6417, 'lng': 69.6293},
    {'name': 'Veraval, Gujarat', 'lat': 20.9070, 'lng': 70.3679},
    {'name': 'Okha, Gujarat', 'lat': 22.4673, 'lng': 69.0706},
    {'name': 'Jamnagar, Gujarat', 'lat': 22.4707, 'lng': 70.0577},
    {'name': 'Dwarka, Gujarat', 'lat': 22.2394, 'lng': 68.9678},
    {'name': 'Karwar, Karnataka', 'lat': 14.8136, 'lng': 74.1297},
    {'name': 'Ratnagiri, Maharashtra', 'lat': 16.9902, 'lng': 73.3120},
    {'name': 'Alibag, Maharashtra', 'lat': 18.6414, 'lng': 72.8722},
    {'name': 'Vasco da Gama, Goa', 'lat': 15.3860, 'lng': 73.8440},
    {'name': 'Panaji, Goa', 'lat': 15.4909, 'lng': 73.8278},
    {'name': 'Haldia, West Bengal', 'lat': 22.0667, 'lng': 88.0698},
    {'name': 'Machilipatnam, Andhra Pradesh', 'lat': 16.1875, 'lng': 81.1389},
    {'name': 'Nellore, Andhra Pradesh', 'lat': 14.4426, 'lng': 79.9865},
    {'name': 'Gopalpur, Odisha', 'lat': 19.2750, 'lng': 84.9050},
    {'name': 'Mandvi, Gujarat', 'lat': 22.8323, 'lng': 69.3524},
    {'name': 'Bhavnagar, Gujarat', 'lat': 21.7645, 'lng': 72.1519},
    {'name': 'Kanyakumari, Tamil Nadu', 'lat': 8.0883, 'lng': 77.5385},
  ];

  // Sample Indian names
  final firstNames = [
    'Aarav','Vihaan','Vivaan','Aditya','Arjun','Reyansh','Muhammad','Sai','Krishna','Ishaan','Ananya','Aadhya','Diya','Janhvi','Kiara','Navya','Saanvi','Zara','Meera','Aarohi'
  ];
  final lastNames = [
    'Sharma','Verma','Iyer','Reddy','Rao','Patel','Singh','Khan','Das','Ghosh','Mukherjee','Nair','Menon','Shetty','Pillai','Chowdhury','Yadav','Chauhan','Gowda','Gupta'
  ];

  final hazardTypes = ['tsunami','stormSurge','highWaves','coastalFlooding','abnormalTides','coastalErosion','other'];
  final severities = ['low','medium','high','critical'];
  final statuses = ['pending','verified','rejected','underReview'];

  final now = DateTime.now().toUtc();
  final List<Map<String, dynamic>> reports = [];

  for (int i = 1; i <= 500; i++) {
    final city = coastalCities[i % coastalCities.length];
    final name = '${firstNames[rng.nextInt(firstNames.length)]} ${lastNames[rng.nextInt(lastNames.length)]}';
    final hazard = hazardTypes[i % hazardTypes.length];
    final severity = severities[(i ~/ 7) % severities.length];
    final status = statuses[(i ~/ 5) % statuses.length];

    // Slight jitter around city coords to avoid exact duplicates
    final lat = (city['lat'] as double) + (rng.nextDouble() - 0.5) * 0.05; // ~5km jitter
    final lng = (city['lng'] as double) + (rng.nextDouble() - 0.5) * 0.05;

    final createdAt = now.subtract(Duration(hours: rng.nextInt(24 * 14))); // last 2 weeks
    final updatedAt = createdAt.add(Duration(hours: rng.nextInt(24)));

    final id = 'rpt_${i.toString().padLeft(3, '0')}';
    final userId = 'user_${(1000 + i).toString()}';

    reports.add({
      'id': id,
      'userId': userId,
      'userName': name,
      'hazardType': hazard,
      'title': _titleForHazard(hazard),
      'description': _descriptionForHazard(hazard),
      'latitude': double.parse(lat.toStringAsFixed(6)),
      'longitude': double.parse(lng.toStringAsFixed(6)),
      'address': city['name'],
      'mediaUrls': [
        'https://example.com/images/${id}_1.jpg',
        'https://example.com/videos/${id}_1.mp4'
      ],
      'status': status,
      'severity': severity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'verifiedBy': status == 'verified' ? 'official_${100 + (i % 50)}' : null,
      'verifiedAt': status == 'verified' ? updatedAt.toIso8601String() : null,
      'verificationNotes': status == 'verified' ? 'Verified by coastal authority' : null,
      'metadata': {
        'source': 'mobile',
        'tags': [hazard, severity]
      },
      'isOffline': false,
    });
  }

  final outDir = Directory('assets/data');
  if (!await outDir.exists()) {
    await outDir.create(recursive: true);
  }
  final outFile = File('assets/data/reports_india.json');
  await outFile.writeAsString(const JsonEncoder.withIndent('  ').convert(reports));

  // Print where the file is written
  // ignore: avoid_print
  print('Generated ${reports.length} reports at ${outFile.path}');
}

String _titleForHazard(String hazard) {
  switch (hazard) {
    case 'tsunami':
      return 'Tsunami warning issued';
    case 'stormSurge':
      return 'Storm surge risk along coast';
    case 'highWaves':
      return 'High waves observed near shore';
    case 'coastalFlooding':
      return 'Coastal flooding in low-lying areas';
    case 'abnormalTides':
      return 'Abnormal tides reported';
    case 'coastalErosion':
      return 'Coastal erosion visible';
    default:
      return 'Other coastal hazard reported';
  }
}

String _descriptionForHazard(String hazard) {
  switch (hazard) {
    case 'tsunami':
      return 'Authorities have issued an advisory for potential tsunami activity.';
    case 'stormSurge':
      return 'Strong winds and rising sea levels could cause storm surge impacts.';
    case 'highWaves':
      return 'Waves reaching dangerous heights; avoid swimming and boating.';
    case 'coastalFlooding':
      return 'Water level rising in residential areas near the coast.';
    case 'abnormalTides':
      return 'Unusual tide patterns observed by local authorities and fishermen.';
    case 'coastalErosion':
      return 'Visible shoreline retreat and sand loss reported.';
    default:
      return 'Citizen-reported coastal hazard; verification pending.';
  }
}
