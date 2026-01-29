import 'package:flutter/material.dart';
import 'app.dart';
import 'services/server.dart';

// ============================================================================
// LITEWORSHIP — Entry Point
// LOCAL SERVER ARCHITECTURE: Hosting Kiosk Mode Projector
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start the Local Web Server (Assets + WebSocket)
  await startProjectorServer();

  // Launch the Dashboard App
  runApp(const LiteWorshipApp(windowType: 'dashboard'));
}
