import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/offline_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../models/report_model.dart';
import '../widgets/hazard_type_selector.dart';
import '../widgets/severity_selector.dart';
import '../widgets/media_upload_widget.dart';
import '../widgets/location_picker_widget.dart';

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  HazardType _selectedHazardType = HazardType.other;
  ReportSeverity _selectedSeverity = ReportSeverity.medium;
  Position? _currentPosition;
  String? _currentAddress;
  List<String> _mediaUrls = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      final position = await LocationService.instance.getCurrentPosition();
      if (position != null) {
        setState(() => _currentPosition = position);
        
        final address = await LocationService.instance.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        setState(() => _currentAddress = address);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location for your report'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final report = ReportModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id', // TODO: Get from auth provider
        userName: 'Current User', // TODO: Get from auth provider
        hazardType: _selectedHazardType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: _currentAddress,
        mediaUrls: _mediaUrls,
        severity: _selectedSeverity,
        createdAt: DateTime.now(),
        isOffline: !OfflineService.isOnline,
      );

      if (OfflineService.isOnline) {
        // TODO: Submit to API
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      } else {
        // Save offline
        await OfflineService.saveOfflineReport(report);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              OfflineService.isOnline 
                ? 'Report submitted successfully!'
                : 'Report saved offline and will sync when connected',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailAppBar(
        title: 'Report Ocean Hazard',
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hazard Type Selection
              Text(
                'Hazard Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              HazardTypeSelector(
                selectedType: _selectedHazardType,
                onChanged: (type) => setState(() => _selectedHazardType = type),
              ),

              const SizedBox(height: 24),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Report Title',
                  hintText: 'Brief description of the hazard',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title for your report';
                  }
                  if (value.trim().length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Detailed description of what you observed',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Severity Selection
              Text(
                'Severity Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SeveritySelector(
                selectedSeverity: _selectedSeverity,
                onChanged: (severity) => setState(() => _selectedSeverity = severity),
              ),

              const SizedBox(height: 24),

              // Location Section
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LocationPickerWidget(
                position: _currentPosition,
                address: _currentAddress,
                isLoading: _isLoading,
                onLocationChanged: (position, address) {
                  setState(() {
                    _currentPosition = position;
                    _currentAddress = address;
                  });
                },
                onRefreshLocation: _getCurrentLocation,
              ),

              const SizedBox(height: 24),

              // Media Upload
              Text(
                'Photos/Videos (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              MediaUploadWidget(
                mediaUrls: _mediaUrls,
                onMediaChanged: (urls) => setState(() => _mediaUrls = urls),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dangerColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting...'),
                          ],
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Offline Indicator
              if (!OfflineService.isOnline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        color: AppTheme.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You are offline. Your report will be saved and synced when you reconnect.',
                          style: TextStyle(
                            color: AppTheme.warningColor,
                            fontSize: 12,
                          ),
                        ),
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
}
