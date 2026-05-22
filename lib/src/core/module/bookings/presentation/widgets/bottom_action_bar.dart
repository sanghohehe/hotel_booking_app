import 'package:flutter/material.dart';

class BottomAction extends StatelessWidget {
  final bool isLoading;
  final bool isDisabled;
  final double totalPrice;
  final VoidCallback onPressed;

  const BottomAction({
    super.key,
    required this.isLoading,
    required this.isDisabled,
    required this.totalPrice,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled ? Colors.grey : theme.primaryColor,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child:
              isLoading
                  ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    isDisabled
                        ? 'Số khách không hợp lệ'
                        : 'Xác nhận & Thanh toán',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }
}
