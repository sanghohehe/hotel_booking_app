import 'package:flutter/material.dart';
import '../../cubit/chatbot_state.dart';

class ChatbotInputArea extends StatelessWidget {
  final ChatbotState state;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onChanged;

  const ChatbotInputArea({
    super.key,
    required this.state,
    required this.controller,
    required this.onSend,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSend(),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onChanged: (_) => onChanged(),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1C1C1E),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: state.isSending ? null : onSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      (controller.text.trim().isNotEmpty && !state.isSending)
                          ? const Color(0xFF0A84FF)
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color:
                      (controller.text.trim().isNotEmpty && !state.isSending)
                          ? Colors.white
                          : Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
