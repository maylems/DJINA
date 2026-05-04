// Widget: Interface d'appel téléphonique (bouton raccrocher)
import 'package:flutter/material.dart';

class CallInterface extends StatelessWidget {
  final String driverName;
  final String driverPhone;
  final Duration callDuration;
  final VoidCallback? onEndCall;

  const CallInterface({
    super.key,
    required this.driverName,
    required this.driverPhone,
    this.callDuration = Duration.zero,
    this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green[100],
            child: const Icon(Icons.person, color: Colors.green),
          ),
          const SizedBox(width: 15),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  driverPhone,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Durée appel
          if (callDuration > Duration.zero)
            Text(
              _formatDuration(callDuration),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),

          // Raccrocher
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: onEndCall,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes;
    final sec = d.inSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
