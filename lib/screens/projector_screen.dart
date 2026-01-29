import 'package:flutter/material.dart';

// ============================================================================
// LITEWORSHIP — Projector Screen (Legacy/Placeholder)
// This flutter screen is no longer used in the Local Server architecture.
// The actual projector is now a Chrome Kiosk window.
// ============================================================================

class ProjectorScreen extends StatelessWidget {
  const ProjectorScreen({super.key, this.windowId, this.args});

  final int? windowId;
  final Map? args;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Use Chrome Browser on port 8080',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
