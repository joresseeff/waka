import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/mission.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onTap;

  const MissionCard({super.key, required this.mission, this.onTap});

  Color get _statusColor {
    switch (mission.status) {
      case 'pending':     return Colors.orange;
      case 'negotiating': return Colors.purple;
      case 'accepted':    return WakaTheme.primary;
      case 'in_progress': return Colors.blue;
      case 'completed':   return WakaTheme.success;
      case 'cancelled':   return WakaTheme.error;
      default:            return WakaTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(mission.serviceLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: WakaTheme.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(mission.statusLabel,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _addressRow(Icons.my_location, mission.fromAddr, mission.fromLandmark),
              const SizedBox(height: 4),
              _addressRow(Icons.location_on, mission.toAddr, mission.toLandmark),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(mission.paymentLabel,
                    style: const TextStyle(fontSize: 12, color: WakaTheme.textGrey),
                  ),
                  Text(
                    '${(mission.priceFinal ?? mission.priceProposed).toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: WakaTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressRow(IconData icon, String addr, String? landmark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: WakaTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(addr,
                style: const TextStyle(fontSize: 13, color: WakaTheme.textDark),
                overflow: TextOverflow.ellipsis,
              ),
              if (landmark != null)
                Text(landmark,
                  style: const TextStyle(fontSize: 11, color: WakaTheme.textGrey),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
