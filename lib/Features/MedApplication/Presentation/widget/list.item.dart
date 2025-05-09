import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/adminWrapper.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';

class PatientListItem extends StatelessWidget {
  final PatientProfile profile;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PatientListItem({
    super.key,
    required this.profile,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return _buildListItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    return AdminWrapper(
      (context, provider) {
        return Card(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                    RouteGenerator.patientApplicationScreen,
                    arguments: profile),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Full Name', profile.fullName),
                      _buildInfoRow('Email', profile.email ?? ""),
                      _buildInfoRow('Address', profile.address ?? ""),
                      _buildInfoRow('Contact', profile.contactNumber ?? ""),
                      if (profile.dob != null)
                        _buildInfoRow('Date of Birth', profile.dob.toString()),
                      // _buildInfoRow('Reg. Date', _formatDate(profile.registrationDate)),
                      const SizedBox(height: 8),
                      if (profile.verificationStatus != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: profile.verificationStatus?.color ??
                                Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            profile.verificationStatus!.displayName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (provider.user!.isStaff &&
                  profile.verificationStatus == ApplicationStatus.PENDING)
                Positioned(
                  right: 0,
                  top: 0,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'approve',
                        child: ListTile(
                          leading: Icon(Icons.check_circle, color: Colors.blue),
                          title: Text('Approve'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'reject',
                        child: ListTile(
                          leading: Icon(Icons.close, color: Colors.red),
                          title: Text('Reject'),
                        ),
                      ),
                    ],
                    onSelected: (String value) {
                      if (value == 'approve') onApprove();
                      if (value == 'reject') onReject();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getRoleColor(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'super admin':
        return Colors.red.shade700;
      case 'staff':
        return Theme.of(context).primaryColor;
      default:
        return Colors.grey.shade600;
    }
  }
}
