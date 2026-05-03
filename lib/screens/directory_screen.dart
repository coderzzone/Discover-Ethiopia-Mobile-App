import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/app_models.dart';
import '../widgets/ui_components.dart';
import 'service_detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EthioColors.background,
      appBar: AppBar(
        title: const Text('Directory & Services', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        backgroundColor: EthioColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          const SizedBox(height: 10),
          _buildSection(
            context,
            title: 'Top Rated Hotels',
            subtitle: 'Find comfortable stays across Ethiopia',
            icon: Icons.hotel_rounded,
            color: EthioColors.primary,
            items: sampleHotels,
            itemBuilder: (item) => _HotelCard(hotel: item as Hotel),
          ),
          const SizedBox(height: 30),
          _buildSection(
            context,
            title: 'Car Rentals',
            subtitle: 'Rent a vehicle for your adventure',
            icon: Icons.directions_car_rounded,
            color: EthioColors.secondary,
            items: sampleCarRentals,
            itemBuilder: (item) => _CarRentalCard(car: item as CarRental),
          ),
          const SizedBox(height: 30),
          _buildSection(
            context,
            title: 'Tour Agencies',
            subtitle: 'Guided tours and local experts',
            icon: Icons.tour_rounded,
            color: EthioColors.tertiary,
            items: sampleTourAgencies,
            itemBuilder: (item) => _TourAgencyCard(agency: item as TourAgency),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<dynamic> items,
    required Widget Function(dynamic) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: EthioColors.mutedInk, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => SizedBox(
              width: 200,
              child: itemBuilder(items[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({required this.hotel});
  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ServiceDetailScreen(service: hotel),
        ));
      },
      child: _DirectoryCard(
        title: hotel.name,
        subtitle: hotel.pricePerNight,
        rating: hotel.rating,
        imageUrl: hotel.imageUrl,
        color: EthioColors.primary,
      ),
    );
  }
}

class _CarRentalCard extends StatelessWidget {
  const _CarRentalCard({required this.car});
  final CarRental car;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ServiceDetailScreen(service: car),
        ));
      },
      child: _DirectoryCard(
        title: car.name,
        subtitle: '${car.carType} • ${car.pricePerDay}',
        rating: car.rating,
        imageUrl: car.imageUrl,
        color: EthioColors.secondary,
      ),
    );
  }
}

class _TourAgencyCard extends StatelessWidget {
  const _TourAgencyCard({required this.agency});
  final TourAgency agency;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ServiceDetailScreen(service: agency),
        ));
      },
      child: _DirectoryCard(
        title: agency.name,
        subtitle: '${agency.specialty}\n${agency.contact}',
        rating: agency.rating,
        imageUrl: agency.imageUrl,
        color: EthioColors.tertiary,
      ),
    );
  }
}

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.imageUrl,
    required this.color,
  });

  final String title;
  final String subtitle;
  final double rating;
  final String imageUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: color.withValues(alpha: 0.15),
                  child: Icon(Icons.image_not_supported_rounded, color: color),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: EthioColors.mutedInk, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
