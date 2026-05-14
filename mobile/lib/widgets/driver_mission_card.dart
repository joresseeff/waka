import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/mission.dart';

class DriverMissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onAccept;
  final VoidCallback onNegotiate;

  const DriverMissionCard({
    super.key,
    required this.mission,
    required this.onAccept,
    required this.onNegotiate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(mission.serviceLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: WakaTheme.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: WakaTheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${mission.priceProposed.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: WakaTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Adresses
            Row(
              children: [
                const Icon(Icons.my_location, color: WakaTheme.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.fromAddr,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      if (mission.fromLandmark != null)
                        Text(mission.fromLandmark!,
                          style: const TextStyle(color: WakaTheme.textGrey, fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 9),
              child: SizedBox(
                height: 16,
                child: VerticalDivider(color: WakaTheme.divider, width: 2),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: WakaTheme.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.toAddr,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      if (mission.toLandmark != null)
                        Text(mission.toLandmark!,
                          style: const TextStyle(color: WakaTheme.textGrey, fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Paiement
            Row(
              children: [
                const Icon(Icons.payment, size: 14, color: WakaTheme.textGrey),
                const SizedBox(width: 4),
                Text(mission.paymentLabel,
                  style: const TextStyle(color: WakaTheme.textGrey, fontSize: 12),
                ),
                if (mission.description != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.info_outline, size: 14, color: WakaTheme.textGrey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(mission.description!,
                      style: const TextStyle(color: WakaTheme.textGrey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onNegotiate,
                    icon: const Icon(Icons.handshake_outlined, size: 16),
                    label: const Text('Négocier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WakaTheme.primary,
                      side: const BorderSide(color: WakaTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accepter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WakaTheme.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
