import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// GLOBAL SINK (Simple solution for global access)
WebSocketChannel? _projectorChannel;
var projectorSink; // Using dynamic because Sink type can vary slightly

Future<void> startProjectorServer() async {
  // Handler for /ws
  final wsHandler = webSocketHandler((WebSocketChannel webSocket) {
    debugPrint('WebSocket Client Connected');
    _projectorChannel = webSocket;
    projectorSink = webSocket.sink;
    
    // Optional: Log incoming messages
    webSocket.stream.listen((message) {
      debugPrint('WS Received: $message');
    }, onDone: () {
      debugPrint('WebSocket Client Disconnected');
      projectorSink = null;
    });
  });

  // Main Handler
  FutureOr<Response> _handler(Request request) {
    final path = request.url.path;

    if (path == 'ws') {
      return wsHandler(request);
    }

    if (path == '' || path == '/' || path == 'index.html') {
       final file = File('assets/projector.html');
       if (!file.existsSync()) return Response.notFound('projector.html missing');
       return Response.ok(file.openRead(), headers: {'content-type': 'text/html'});
    }

    if (path.startsWith('motion/')) {
        // Serve video file
        final filename = path.replaceFirst('motion/', '');
        final file = File('assets/motion/$filename');
        if (!file.existsSync()) return Response.notFound('Video not found');
        
        final mimeType = lookupMimeType(filename) ?? 'video/mp4';
        return Response.ok(file.openRead(), headers: {'content-type': mimeType});
    }

    return Response.notFound('Not Found');
  }

  // Start Server
  try {
    final handler = const Pipeline().addMiddleware(logRequests()).addHandler(_handler);
    final server = await io.serve(handler, 'localhost', 8080);
    debugPrint('Serving at http://${server.address.host}:${server.port}');
  } catch (e) {
    debugPrint('Error starting server: $e');
  }
}

// Global helper to send messages
void sendProjectorMessage(Map<String, dynamic> data) {
  debugPrint('sendProjectorMessage called with: $data');
  if (projectorSink != null) {
      debugPrint('Sending to projector...');
      projectorSink.add(jsonEncode(data));
      debugPrint('Sent successfully!');
  } else {
    debugPrint('Cannot send message: Projector Disconnected (projectorSink is null)');
  }
}
