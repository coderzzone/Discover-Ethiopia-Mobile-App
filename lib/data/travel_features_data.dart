import '../models/travel_features_models.dart';

const List<BankInfo> ethiopianBanks = [
  BankInfo(name: 'Commercial Bank of Ethiopia', shortCode: 'CBE', branches: [
    BankBranch(name: 'Bole Branch', city: 'Addis Ababa', address: 'Bole Road, near Edna Mall', lat: 8.9975, lng: 38.7870),
    BankBranch(name: 'Piazza Branch', city: 'Addis Ababa', address: 'Arada, Churchill Ave', lat: 9.0402, lng: 38.7508),
    BankBranch(name: 'Bahir Dar Main', city: 'Bahir Dar', address: 'Kebele 14, Main Road', lat: 11.5941, lng: 37.3908),
  ]),
  BankInfo(name: 'Dashen Bank', shortCode: 'Dashen', branches: [
    BankBranch(name: 'Bole Atlas Branch', city: 'Addis Ababa', address: 'Bole Atlas, Cameroon St', lat: 8.9898, lng: 38.7920),
    BankBranch(name: 'Megenagna Branch', city: 'Addis Ababa', address: 'Megenagna Roundabout', lat: 9.0096, lng: 38.7991),
    BankBranch(name: 'Hawassa Branch', city: 'Hawassa', address: 'Piassa Area', lat: 7.0582, lng: 38.4760),
  ]),
  BankInfo(name: 'Awash Bank', shortCode: 'Awash', branches: [
    BankBranch(name: 'Legehar Branch', city: 'Addis Ababa', address: 'Legehar, Ras Abebe Aregay St', lat: 9.0227, lng: 38.7520),
    BankBranch(name: 'Gondar Branch', city: 'Gondar', address: 'Azezo Road', lat: 12.6020, lng: 37.4671),
    BankBranch(name: 'Adama Branch', city: 'Adama', address: 'Kebele 09, Main Avenue', lat: 8.5412, lng: 39.2695),
  ]),
  BankInfo(name: 'Abyssinia Bank', shortCode: 'BoA', branches: [
    BankBranch(name: 'Mexico Branch', city: 'Addis Ababa', address: 'Mexico Square', lat: 9.0102, lng: 38.7415),
    BankBranch(name: 'CMC Branch', city: 'Addis Ababa', address: 'CMC, Ayat Road', lat: 9.0420, lng: 38.8540),
  ]),
  BankInfo(name: 'Abay Bank', shortCode: 'Abay', branches: [
    BankBranch(name: 'Sar Bet Branch', city: 'Addis Ababa', address: 'Sar Bet, Ring Road', lat: 8.9740, lng: 38.7336),
    BankBranch(name: 'Bahir Dar Branch', city: 'Bahir Dar', address: 'Belay Zeleke Rd', lat: 11.6028, lng: 37.3843),
  ]),
  BankInfo(name: 'Wegagen Bank', shortCode: 'Wegagen', branches: [
    BankBranch(name: 'Kazanchis Branch', city: 'Addis Ababa', address: 'Kazanchis, Guinea Conakry St', lat: 9.0194, lng: 38.7638),
    BankBranch(name: 'Mekelle Branch', city: 'Mekelle', address: 'Hawelti Area', lat: 13.4967, lng: 39.4762),
  ]),
  BankInfo(name: 'Nib International Bank', shortCode: 'NIB', branches: [
    BankBranch(name: 'Megenagna Branch', city: 'Addis Ababa', address: 'Megenagna, Anbessa Garage', lat: 9.0106, lng: 38.7970),
    BankBranch(name: 'Jimma Branch', city: 'Jimma', address: 'Merkato Area', lat: 7.6736, lng: 36.8344),
  ]),
  BankInfo(name: 'Cooperative Bank of Oromia', shortCode: 'Coop', branches: [
    BankBranch(name: 'Bole Medhanialem', city: 'Addis Ababa', address: 'Bole Medhanialem', lat: 8.9925, lng: 38.7888),
    BankBranch(name: 'Nekemte Branch', city: 'Nekemte', address: 'Kenyatta St', lat: 9.0861, lng: 36.5506),
  ]),
  BankInfo(name: 'Bunna Bank', shortCode: 'Bunna', branches: [
    BankBranch(name: 'Gerji Branch', city: 'Addis Ababa', address: 'Gerji Mebrat Hayl', lat: 8.9995, lng: 38.8124),
    BankBranch(name: 'Bahir Dar Branch', city: 'Bahir Dar', address: 'Giorgis Area', lat: 11.5955, lng: 37.3874),
  ]),
  BankInfo(name: 'Zemen Bank', shortCode: 'Zemen', branches: [
    BankBranch(name: 'Main Branch', city: 'Addis Ababa', address: 'Bole, Africa Ave', lat: 8.9969, lng: 38.7865),
  ]),
];

const List<PhraseItem> samplePhrases = [
  PhraseItem(amharic: 'Selam', english: 'Hello', pronunciation: 'seh-lam', category: 'Greetings'),
  PhraseItem(amharic: 'Dehna neh?', english: 'How are you?', pronunciation: 'deh-na neh', category: 'Greetings'),
  PhraseItem(amharic: 'Waga sint new?', english: 'How much is it?', pronunciation: 'wa-ga sint new', category: 'Bargaining'),
  PhraseItem(amharic: 'Betam wud new', english: 'It is too expensive', pronunciation: 'beh-tam wood new', category: 'Bargaining'),
  PhraseItem(amharic: 'Erdagn', english: 'Help me', pronunciation: 'er-da-gn', category: 'Emergencies'),
  PhraseItem(amharic: 'Hospital yet new?', english: 'Where is the hospital?', pronunciation: 'hos-pi-tal yet new', category: 'Emergencies'),
  PhraseItem(amharic: 'Yih menged yet yhedal?', english: 'Where does this road go?', pronunciation: 'yih men-ged yet y-he-dal', category: 'Directions'),
  PhraseItem(amharic: 'Taxi yet argalehu?', english: 'Where can I get a taxi?', pronunciation: 'taxi yet ar-ga-le-hu', category: 'Directions'),
  PhraseItem(amharic: 'Amesegenallo', english: 'Thank you', pronunciation: 'ah-meh-seh-ge-na-lo', category: 'Greetings'),
  PhraseItem(amharic: 'Yikirta', english: 'Excuse me / Sorry', pronunciation: 'yee-kir-ta', category: 'Greetings'),
  PhraseItem(amharic: 'Kenesu yigeremal?', english: 'Can you reduce the price?', pronunciation: 'keh-neh-su yee-geh-reh-mal', category: 'Bargaining'),
  PhraseItem(amharic: 'Birr kebelehu', english: 'I pay in birr', pronunciation: 'beer ke-beh-le-hu', category: 'Bargaining'),
  PhraseItem(amharic: 'Police yet new?', english: 'Where is the police?', pronunciation: 'po-lee-seh yet new', category: 'Emergencies'),
  PhraseItem(amharic: 'Doctor felegalehu', english: 'I need a doctor', pronunciation: 'dok-tor feh-leh-ga-le-hu', category: 'Emergencies'),
  PhraseItem(amharic: 'Menegdu yemitawoq', english: 'I am lost', pronunciation: 'meh-neg-du yee-mee-ta-wok', category: 'Directions'),
  PhraseItem(amharic: 'Bole airport yet new?', english: 'Where is Bole airport?', pronunciation: 'bo-le air-port yet new', category: 'Directions'),
];

const List<DestinationCompare> destinationComparisons = [
  DestinationCompare(
    name: 'Danakil Depression',
    difficulty: 'High',
    cost: 'High',
    bestSeason: 'Nov-Feb',
    timeNeeded: '3-4 days',
    recommendedDuration: '4 days',
  ),
  DestinationCompare(
    name: 'Simien Mountains',
    difficulty: 'Medium-High',
    cost: 'Medium',
    bestSeason: 'Oct-May',
    timeNeeded: '2-6 days',
    recommendedDuration: '4 days',
  ),
  DestinationCompare(
    name: 'Lalibela',
    difficulty: 'Low-Medium',
    cost: 'Medium',
    bestSeason: 'Oct-Mar',
    timeNeeded: '1-3 days',
    recommendedDuration: '2 days',
  ),
  DestinationCompare(
    name: 'Omo Valley',
    difficulty: 'Medium',
    cost: 'Medium-High',
    bestSeason: 'Jun-Sep',
    timeNeeded: '3-5 days',
    recommendedDuration: '4 days',
  ),
];

Map<String, List<PackingItem>> packingByRegion = {
  'Danakil': const [
    PackingItem(label: '5L+ water capacity', critical: true),
    PackingItem(label: 'Sun hat + SPF 50+', critical: true),
    PackingItem(label: 'Head lamp', critical: true),
    PackingItem(label: 'Electrolyte packs'),
  ],
  'Simiens': const [
    PackingItem(label: '-10C sleeping bag', critical: true),
    PackingItem(label: 'Hiking poles', critical: true),
    PackingItem(label: 'Altitude medication', critical: true),
    PackingItem(label: 'Layered thermal clothing'),
  ],
  'Church Visits': const [
    PackingItem(label: 'Shoulder and knee covering', critical: true),
    PackingItem(label: 'Easy-removal socks', critical: true),
    PackingItem(label: 'Light scarf'),
  ],
};
