import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'dart:io';

import '../config/theme.dart';
import '../widgets/library_panel.dart';
import '../widgets/schedule_panel.dart';
import '../widgets/preview_panel.dart';

class ControlDashboard extends ConsumerStatefulWidget {
  const ControlDashboard({super.key});

  @override
  ConsumerState<ControlDashboard> createState() => _ControlDashboardState();
}

class _ControlDashboardState extends ConsumerState<ControlDashboard> {
  // Multi-Monitor State
  List<Display> _displays = [];
  Display? _selectedDisplay;
  bool _isLoadingDisplays = false;

  @override
  void initState() {
    super.initState();
    _loadDisplays();
  }

  Future<void> _loadDisplays() async {
    setState(() => _isLoadingDisplays = true);
    try {
      final displays = await ScreenRetriever.instance.getAllDisplays();
      setState(() {
        _displays = displays;
        if (displays.length > 1) {
          _selectedDisplay = displays[1]; // Default to second screen
        } else if (displays.isNotEmpty) {
          _selectedDisplay = displays[0];
        }
      });
    } catch (e) {
      debugPrint('Error loading displays: $e');
    } finally {
      if (mounted) setState(() => _isLoadingDisplays = false);
    }
  }

  Future<void> _launchChromeKiosk() async {
    if (_selectedDisplay == null) return;
    
    try {
      final x = _selectedDisplay!.visiblePosition?.dx.toInt() ?? 0;
      final y = _selectedDisplay!.visiblePosition?.dy.toInt() ?? 0;

      await Process.run(
        'start',
        [
          'chrome',
          '--new-window',
          '--window-position=$x,$y',
          '--kiosk',
          'http://localhost:8080'
        ],
        runInShell: true,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Launching Projector on Display ${_selectedDisplay!.id}')),
      );
    } catch (e) {
      debugPrint('Error launching Chrome: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LWColors.background,
      appBar: AppBar(
        title: const Text('LiteWorship Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.monitor),
            tooltip: "Setup Projector",
            onPressed: () => _showProjectorSetup(),
          ),
          IconButton(
             icon: const Icon(Icons.play_circle_fill),
             tooltip: "Launch Projector (Chrome)",
             onPressed: _launchChromeKiosk,
          ), 
        ],
      ),
      body: Column(
        children: [
          // TOP SECTION: ACTIVE CONTROLS (Live + Preview)
          const Expanded(
            flex: 6,
            child: PreviewPanel(),
          ),
          const Divider(height: 1, thickness: 1, color: LWColors.border),
          
          // BOTTOM SECTION: LIBRARY (FULL WIDTH)
          const Expanded(
            flex: 4,
            child: LibraryPanel(),
          ),
        ],
      ),
    );
  }

  void _showProjectorSetup() {
      showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Projector Setup'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoadingDisplays)
                  const CircularProgressIndicator()
                else if (_displays.isEmpty)
                  const Text('No displays detected.')
                else
                  DropdownButton<Display>(
                    isExpanded: true,
                    value: _selectedDisplay,
                    hint: const Text('Select Target Display'),
                    items: _displays.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text('${d.id}: ${d.size.width.toInt()}x${d.size.height.toInt()}'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        _selectedDisplay = val;
                      });
                      setState(() {
                         _selectedDisplay = val;
                      });
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('DONE')),
            ],
          );
        },
      ),
    );
  }
}
