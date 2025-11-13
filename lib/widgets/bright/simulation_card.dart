import 'package:flutter/material.dart';
import '../../models/simulation.dart' as sim;
import '../../design_system/junior_theme.dart';

/// Simulation card widget styled like game cards from Junior dashboard
class SimulationCard extends StatelessWidget {
  final sim.Simulation simulation;
  final VoidCallback onTap;
  final Color color;

  const SimulationCard({
    super.key,
    required this.simulation,
    required this.onTap,
    this.color = const Color(0xFF5B9BD5),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
          border: Border.all(
            color: color,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  _getIcon(),
                  size: 36,
                  color: color,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                simulation.title,
                style: JuniorTheme.headingSmall.copyWith(
                  fontSize: 16,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Time estimate
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${simulation.estimatedMinutes} mins',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Start button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Explore',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    // Return appropriate icon based on simulation ID
    if (simulation.id.contains('states-of-matter')) {
      return Icons.water_drop_outlined;
    } else if (simulation.id.contains('energy')) {
      return Icons.flash_on_outlined;
    } else if (simulation.id.contains('gravity')) {
      return Icons.public_outlined;
    } else if (simulation.id.contains('circuit')) {
      return Icons.electrical_services_outlined;
    } else {
      return Icons.science_outlined;
    }
  }
}
