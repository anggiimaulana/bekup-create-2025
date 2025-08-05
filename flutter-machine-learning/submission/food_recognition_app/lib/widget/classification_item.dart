import 'package:flutter/material.dart';

class ClassificationItem extends StatelessWidget {
  final String item;
  final String value;

  const ClassificationItem({
    super.key,
    required this.item,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          // Food icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // Food name and confidence
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Confidence: $value',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Confidence badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getConfidenceColor(value),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get color based on confidence percentage
  Color _getConfidenceColor(String confidenceStr) {
    try {
      // Remove % and parse as double
      final confidenceValue = double.tryParse(
        confidenceStr.replaceAll('%', ''),
      );

      if (confidenceValue == null) return Colors.grey;

      if (confidenceValue >= 80) {
        return Colors.green; // High confidence
      } else if (confidenceValue >= 60) {
        return Colors.orange; // Medium confidence
      } else if (confidenceValue >= 40) {
        return Colors.deepOrange; // Low-medium confidence
      } else {
        return Colors.red; // Low confidence
      }
    } catch (e) {
      return Colors.grey; // Default color for parse errors
    }
  }
}
