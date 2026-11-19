import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Standard screen frame: purple safe-area, app background image, optional "keep the screen on".
class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.keepScreenOn = false,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  /// Solid colour instead of the background image (e.g. the Bluetooth-off screen).
  final Color? backgroundColor;

  /// Prevents the screen from sleeping while this screen is shown (used during CPR).
  final bool keepScreenOn;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.keepScreenOn) WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.keepScreenOn) WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.keepScreenOn) return;
    if (state == AppLifecycleState.resumed) {
      WakelockPlus.enable();
    } else if (state == AppLifecycleState.paused) {
      WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final solid = widget.backgroundColor;
    return ColoredBox(
      color: solid ?? AppColors.purple,
      child: SafeArea(
        child: Container(
          decoration: solid != null ? null : const BoxDecoration(image: DecorationImage(image: AssetImage(AppAssets.background), fit: BoxFit.fill)),
          child: Scaffold(
            backgroundColor: solid ?? Colors.transparent,
            body: SizedBox.expand(child: widget.child),
            bottomNavigationBar: widget.bottomNavigationBar,
            floatingActionButton: widget.floatingActionButton,
          ),
        ),
      ),
    );
  }
}
