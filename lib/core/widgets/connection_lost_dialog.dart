import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_text_styles.dart';

/// Blurred "OOPS - Bluetooth lost" dialog with Exit and Retry. It cannot be dismissed any other way.
class ConnectionLostDialog extends StatelessWidget {
  const ConnectionLostDialog({super.key, required this.onExit, required this.onRetry});

  final VoidCallback onExit;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.white, width: 5), color: Colors.deepPurple),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('OOPS', style: AppTextStyles.whiteHugeBold),
                        const Icon(Icons.bluetooth, size: 100, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(AppConstants.bleLostConnectionMessage, textAlign: TextAlign.center, style: AppTextStyles.whiteMedium.copyWith(fontSize: 15)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RoundAction(color: const Color.fromRGBO(241, 116, 6, 1), icon: Icons.arrow_back, onTap: onExit),
                      _RoundAction(color: Colors.green, icon: Icons.refresh, onTap: onRetry),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.color, required this.icon, required this.onTap});

  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 45,
      backgroundColor: Colors.white,
      child: InkWell(borderRadius: BorderRadius.circular(40), onTap: onTap, child: CircleAvatar(maxRadius: 40, backgroundColor: color, child: Icon(icon, size: 45, color: Colors.white))),
    );
  }
}
