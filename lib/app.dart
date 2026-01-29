import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/projector_screen.dart';

// ============================================================================
// LITEWORSHIP — App Widget
// MaterialApp with routing based on window type
// ============================================================================

class LiteWorshipApp extends StatelessWidget {
  const LiteWorshipApp({
    super.key,
    required this.windowType,
    this.windowId,
    this.args,
  });

  /// 'dashboard' for main window, 'projector' for output window
  final String windowType;
  final int? windowId;
  final Map? args;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'LiteWorship',
        debugShowCheckedModeBanner: false,
        theme: LWTheme.darkTheme,
        home: windowType == 'projector'
            ? ProjectorScreen(windowId: windowId, args: args)
            : const ControlDashboard(),
      ),
    );
  }
}
