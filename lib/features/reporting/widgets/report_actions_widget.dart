import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/report_model.dart';

class ReportActionsWidget extends StatelessWidget {
  final ReportModel report;

  const ReportActionsWidget({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Quick actions row
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.location_on,
                label: 'View Location',
                color: AppTheme.primaryColor,
                onTap: () => _viewLocation(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                icon: Icons.share,
                label: 'Share',
                color: AppTheme.secondaryColor,
                onTap: () => _shareReport(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                icon: Icons.bookmark_border,
                label: 'Save',
                color: AppTheme.warningColor,
                onTap: () => _saveReport(context),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Status-specific actions
        if (report.status == ReportStatus.pending) ...[
          _buildPendingActions(context),
        ] else if (report.status == ReportStatus.underReview) ...[
          _buildUnderReviewActions(context),
        ] else if (report.status == ReportStatus.verified) ...[
          _buildVerifiedActions(context),
        ] else if (report.status == ReportStatus.rejected) ...[
          _buildRejectedActions(context),
        ],
      ],
    );
  }

  Widget _buildPendingActions(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppTheme.warningColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'This report is pending review. You can still edit or provide additional information.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
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
                onPressed: () => _editReport(context),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Report'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addMoreInfo(context),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Media'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnderReviewActions(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.rate_review,
              color: AppTheme.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'This report is being reviewed by our team. You will be notified once the review is complete.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _trackReview(context),
            icon: const Icon(Icons.track_changes),
            label: const Text('Track Review Status'),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedActions(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified,
                color: AppTheme.successColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This report has been verified and is being used for hazard monitoring.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewSimilarReports(context),
                icon: const Icon(Icons.search),
                label: const Text('Similar Reports'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewUpdates(context),
                icon: const Icon(Icons.update),
                label: const Text('View Updates'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRejectedActions(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.dangerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.dangerColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cancel,
                color: AppTheme.dangerColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This report could not be verified. You can appeal this decision or submit a new report.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.dangerColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _appealDecision(context),
                icon: const Icon(Icons.gavel),
                label: const Text('Appeal'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.dangerColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _submitNewReport(context),
                icon: const Icon(Icons.add),
                label: const Text('New Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Action handlers
  void _viewLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening location on map...')),
    );
  }

  void _shareReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _saveReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report saved to bookmarks')),
    );
  }

  void _editReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  void _addMoreInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add media functionality coming soon')),
    );
  }

  void _trackReview(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review tracking coming soon')),
    );
  }

  void _viewSimilarReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Similar reports feature coming soon')),
    );
  }

  void _viewUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updates feature coming soon')),
    );
  }

  void _appealDecision(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appeal functionality coming soon')),
    );
  }

  void _submitNewReport(BuildContext context) {
    Navigator.of(context).pushNamed('/report/create');
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
