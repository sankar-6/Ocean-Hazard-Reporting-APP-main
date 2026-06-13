import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_theme.dart';
import '../screens/map_picker_screen.dart';

class LocationPickerWidget extends StatefulWidget {
  final Position? position;
  final String? address;
  final bool isLoading;
  final Function(Position?, String?) onLocationChanged;
  final VoidCallback onRefreshLocation;

  const LocationPickerWidget({
    super.key,
    this.position,
    this.address,
    this.isLoading = false,
    required this.onLocationChanged,
    required this.onRefreshLocation,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialPosition: widget.position,
          initialAddress: widget.address,
        ),
      ),
    );

    if (result != null && mounted) {
      final position = result['position'] as Position?;
      final address = result['address'] as String?;
      widget.onLocationChanged(position, address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Location',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: widget.onRefreshLocation,
                  icon: const Icon(Icons.refresh),
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.position != null && widget.address != null)
            _buildLocationInfo()
          else if (widget.isLoading)
            _buildLoadingState()
          else
            _buildNoLocationState(),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.my_location, size: 16, color: Colors.green[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.address!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.gps_fixed, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${widget.position!.latitude.toStringAsFixed(6)}, ${widget.position!.longitude.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.place, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.address!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openMapPicker(),
                icon: const Icon(Icons.map, size: 16),
                label: const Text('Change Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onRefreshLocation,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Getting your location...',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Please ensure location services are enabled',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildNoLocationState() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.location_off, size: 16, color: Colors.orange[600]),
            const SizedBox(width: 8),
            Text(
              'Location not available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'We need your location to accurately report the hazard. Please enable location services and try again.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onRefreshLocation,
            icon: const Icon(Icons.my_location, size: 16),
            label: const Text('Get My Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openMapPicker(),
            icon: const Icon(Icons.map, size: 16),
            label: const Text('Select on Map'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
