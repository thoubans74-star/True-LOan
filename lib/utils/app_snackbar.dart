import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays a unified premium SnackBar notification driven by API messages
void showAppSnackBar(BuildContext context, String message, {bool isError = false}) {
  if (message.isEmpty) return;

  final ScaffoldMessengerState state = ScaffoldMessenger.of(context);
  state.clearSnackBars();

  state.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError ? const Color(0xFFFEF2F2) : const Color(0xFF004AC6),
          borderRadius: BorderRadius.circular(12),
          border: isError
              ? Border.all(color: const Color(0xFFFCA5A5), width: 1)
              : Border.all(color: const Color(0x33FFFFFF), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: isError ? const Color(0xFF991B1B) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isError ? const Color(0xFF991B1B) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 4),
    ),
  );
}
