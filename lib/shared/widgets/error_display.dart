import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                  color: Colors.red,
                ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
