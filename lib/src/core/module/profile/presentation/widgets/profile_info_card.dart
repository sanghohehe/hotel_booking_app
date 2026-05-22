import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String phoneNumber;
  final String dob;
  final String address;

  const ProfileInfoCard({
    super.key,
    required this.phoneNumber,
    required this.dob,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(
                context,
                icon: Icons.phone_iphone_rounded,
                label: 'Phone',
                value: phoneNumber,
                iconColor: Colors.blue,
              ),
              const Divider(height: 1, indent: 60, endIndent: 20),
              _buildInfoRow(
                context,
                icon: Icons.cake_rounded,
                label: 'Birthday',
                value: dob,
                iconColor: Colors.orange,
              ),
              const Divider(height: 1, indent: 60, endIndent: 20),
              _buildInfoRow(
                context,
                icon: Icons.location_on_rounded,
                label: 'Address',
                value: address,
                iconColor: Colors.redAccent,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
