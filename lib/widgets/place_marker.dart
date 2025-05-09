import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/place.dart';

class PlaceMarker extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceMarker({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        _showPlaceDetails(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXS),
            decoration: const BoxDecoration(
              color: AppColors.accentCyan,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.place,
              color: Colors.white,
              size: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXS,
              vertical: AppDimensions.paddingXS / 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentCyan,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
            ),
            child: Text(
              place.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppDimensions.paddingS),
              Row(
                children: [
                  const Icon(Icons.person, color: AppColors.accentCyan),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text('Ajouté par: ${place.userName}'),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.accentCyan),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text(
                    'Le ${_formatDate(place.createdAt)}',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.accentCyan),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text(
                    '${place.latitude.toStringAsFixed(6)}, ${place.longitude.toStringAsFixed(6)}',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Ouvrir dans Google Maps ou autre app de navigation
                    Navigator.pop(context);
                  },
                  child: const Text('Ouvrir dans Maps'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
