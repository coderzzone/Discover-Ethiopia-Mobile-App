import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/travel_features_data.dart';
import '../models/travel_features_models.dart';
import 'amharic_phrasebook_screen.dart';
import '../widgets/ui_components.dart';

class SmartTravelFeaturesScreen extends StatefulWidget {
  const SmartTravelFeaturesScreen({super.key});

  @override
  State<SmartTravelFeaturesScreen> createState() => _SmartTravelFeaturesScreenState();
}

class _SmartTravelFeaturesScreenState extends State<SmartTravelFeaturesScreen> {
  final Set<String> _packingDone = <String>{};
  final TextEditingController _quizDaysCtrl = TextEditingController(text: '4');

  String _region = 'Danakil';
  String _quizBudget = 'Medium';
  String _quizDifficulty = 'Medium';
  BankInfo _selectedBank = ethiopianBanks.first;
  Position? _userPosition;
  String? _locationError;

  @override
  void dispose() {
    _quizDaysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizPick = _quizResult();
    final checklist = packingByRegion[_region] ?? const <PackingItem>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Travel Features')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _section('Banks in Ethiopia & Nearby Branches'),
          _bankLocatorCard(),
          const SizedBox(height: 16),
          _section('Voice-Activated Amharic Phrasebook (Offline)'),
          _featureLaunchCard(
            title: 'Open Amharic Phrasebook',
            subtitle: 'Dedicated screen with category search and offline phrase actions.',
            icon: Icons.record_voice_over_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AmharicPhrasebookScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _section('Packing List Generator'),
          _packingCard(checklist),
          const SizedBox(height: 16),
          _section('Destination Comparison Tool'),
          _comparisonCard(quizPick),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      );

  Widget _bankLocatorCard() {
    final branches = _sortedBranches(_selectedBank.branches);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<BankInfo>(
            initialValue: _selectedBank,
            decoration: const InputDecoration(labelText: 'Choose bank'),
            items: ethiopianBanks
                .map((bank) => DropdownMenuItem<BankInfo>(value: bank, child: Text('${bank.shortCode} - ${bank.name}')))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedBank = value);
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _detectLocation,
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: const Text('Scan My Location'),
              ),
              if (_userPosition != null)
                Chip(label: Text('Lat ${_userPosition!.latitude.toStringAsFixed(3)}, Lng ${_userPosition!.longitude.toStringAsFixed(3)}')),
            ],
          ),
          if (_locationError != null) ...[
            const SizedBox(height: 8),
            Text(_locationError!, style: const TextStyle(color: EthioColors.error, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 10),
          Text('${_selectedBank.name} branches', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...branches.map((branch) {
            final distance = _distanceKm(branch);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_rounded, color: EthioColors.primary),
              title: Text(branch.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${branch.city} • ${branch.address}${distance == null ? '' : '\n${distance.toStringAsFixed(1)} km away'}'),
            );
          }),
        ],
      ),
    );
  }

  List<BankBranch> _sortedBranches(List<BankBranch> branches) {
    final list = [...branches];
    if (_userPosition == null) return list;
    list.sort((a, b) => _distanceKm(a)!.compareTo(_distanceKm(b)!));
    return list;
  }

  double? _distanceKm(BankBranch branch) {
    if (_userPosition == null) return null;
    final distanceMeters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      branch.lat,
      branch.lng,
    );
    return distanceMeters / 1000;
  }

  Future<void> _detectLocation() async {
    setState(() => _locationError = null);
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationError = 'Location service is disabled on this device.');
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _locationError = 'Location permission denied. Please enable it in settings.');
      return;
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    setState(() => _userPosition = pos);
  }

  Widget _featureLaunchCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: EthioColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: EthioColors.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 27, 27, 26).withValues(alpha: 0.3),
              child: Icon(icon, color: EthioColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: EthioColors.mutedInk, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _packingCard(List<PackingItem> checklist) {
    final completion = checklist.isEmpty ? 0.0 : _packingDone.length / checklist.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _region,
            items: packingByRegion.keys.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() {
              _region = v ?? 'Danakil';
              _packingDone.clear();
            }),
            decoration: const InputDecoration(labelText: 'Region / visit type'),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: completion),
          const SizedBox(height: 8),
          Text('Checklist completion: ${(completion * 100).round()}%'),
          const SizedBox(height: 8),
          ...checklist.map(
            (item) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _packingDone.contains(item.label),
              title: Text(item.label),
              subtitle: item.critical ? const Text('Critical item') : null,
              onChanged: (_) => setState(() {
                if (_packingDone.contains(item.label)) {
                  _packingDone.remove(item.label);
                } else {
                  _packingDone.add(item.label);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonCard(DestinationCompare quizPick) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Side-by-side comparison', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Destination')),
                DataColumn(label: Text('Difficulty')),
                DataColumn(label: Text('Cost')),
                DataColumn(label: Text('Best Season')),
                DataColumn(label: Text('Time Needed')),
                DataColumn(label: Text('Recommended')),
              ],
              rows: destinationComparisons
                  .map(
                    (d) => DataRow(cells: [
                      DataCell(Text(d.name)),
                      DataCell(Text(d.difficulty)),
                      DataCell(Text(d.cost)),
                      DataCell(Text(d.bestSeason)),
                      DataCell(Text(d.timeNeeded)),
                      DataCell(Text(d.recommendedDuration)),
                    ]),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 18),
          const Text('"Which is right for me?" quick quiz', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _quizBudget,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low budget')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium budget')),
                    DropdownMenuItem(value: 'High', child: Text('High budget')),
                  ],
                  onChanged: (v) => setState(() => _quizBudget = v ?? 'Medium'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _quizDifficulty,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Easy')),
                    DropdownMenuItem(value: 'Medium', child: Text('Moderate')),
                    DropdownMenuItem(value: 'High', child: Text('Hard')),
                  ],
                  onChanged: (v) => setState(() => _quizDifficulty = v ?? 'Medium'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _quizDaysCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Available days'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EthioColors.secondaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Best match: ${quizPick.name} | Recommended duration: ${quizPick.recommendedDuration}'),
          ),
        ],
      ),
    );
  }

  DestinationCompare _quizResult() {
    final days = int.tryParse(_quizDaysCtrl.text.trim()) ?? 4;
    final ranked = destinationComparisons.toList();

    ranked.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      if (_quizBudget == 'Low') {
        scoreA += a.cost.contains('Low') ? 3 : 0;
        scoreB += b.cost.contains('Low') ? 3 : 0;
      }
      if (_quizDifficulty == 'Low') {
        scoreA += a.difficulty.contains('Low') ? 2 : 0;
        scoreB += b.difficulty.contains('Low') ? 2 : 0;
      }

      final da = _durationDays(a.recommendedDuration);
      final db = _durationDays(b.recommendedDuration);
      scoreA += max(0, 4 - (da - days).abs());
      scoreB += max(0, 4 - (db - days).abs());
      return scoreB.compareTo(scoreA);
    });

    return ranked.first;
  }

  int _durationDays(String text) {
    final value = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(value) ?? 3;
  }
}
