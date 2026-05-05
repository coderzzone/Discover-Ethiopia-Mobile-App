class AtmSpot {
  const AtmSpot({
    required this.name,
    required this.city,
    required this.bank,
    required this.cashAvailable,
    required this.working,
    required this.lastChecked,
    required this.note,
  });

  final String name;
  final String city;
  final String bank;
  final bool cashAvailable;
  final bool working;
  final String lastChecked;
  final String note;
}

class BankInfo {
  const BankInfo({
    required this.name,
    required this.shortCode,
    required this.branches,
  });

  final String name;
  final String shortCode;
  final List<BankBranch> branches;
}

class BankBranch {
  const BankBranch({
    required this.name,
    required this.city,
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String name;
  final String city;
  final String address;
  final double lat;
  final double lng;
}

class PhraseItem {
  const PhraseItem({
    required this.amharic,
    required this.english,
    required this.pronunciation,
    required this.category,
  });

  final String amharic;
  final String english;
  final String pronunciation;
  final String category;
}

class PackingItem {
  const PackingItem({required this.label, this.critical = false});

  final String label;
  final bool critical;
}

class DestinationCompare {
  const DestinationCompare({
    required this.name,
    required this.difficulty,
    required this.cost,
    required this.bestSeason,
    required this.timeNeeded,
    required this.recommendedDuration,
  });

  final String name;
  final String difficulty;
  final String cost;
  final String bestSeason;
  final String timeNeeded;
  final String recommendedDuration;
}
