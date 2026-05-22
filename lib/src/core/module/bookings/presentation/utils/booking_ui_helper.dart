import 'package:flutter/material.dart';

class BookingUIHelper {
  static String getPaymentLabel(String status) {
    if (['pending', 'unpaid'].contains(status)) return 'Pending';
    if (['canceled', 'cancelled'].contains(status)) return 'Canceled';
    return status[0].toUpperCase() + status.substring(1);
  }

  static Color getPaymentChipBg(BuildContext context, String status) =>
      status == 'paid'
          ? Colors.green.withOpacity(0.15)
          : (['pending', 'unpaid'].contains(status)
              ? Colors.orange.withOpacity(0.15)
              : Colors.grey.withOpacity(0.15));

  static Color getPaymentChipTextColor(String status) =>
      status == 'paid'
          ? Colors.green.shade800
          : (['pending', 'unpaid'].contains(status)
              ? Colors.orange.shade800
              : Colors.grey.shade800);

  static Color getStatusChipBg(String status) {
    if (status == 'confirmed') return Colors.green.withOpacity(0.15);
    if (status == 'done') return Colors.blue.withOpacity(0.15);
    if (status == 'pending') return Colors.orange.withOpacity(0.15);
    return Colors.red.withOpacity(0.15);
  }

  static Color getStatusChipText(String status) {
    if (status == 'confirmed') return Colors.green.shade800;
    if (status == 'done') return Colors.blue.shade800;
    if (status == 'pending') return Colors.orange.shade800;
    return Colors.red.shade800;
  }
}
