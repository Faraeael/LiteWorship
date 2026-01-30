
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class GitHubBibleFile {
  final String name;      // "ACV"
  final String path;      // "formats/json/ACV.json"
  final String downloadUrl; 

  GitHubBibleFile({
    required this.name, 
    required this.path,
    required this.downloadUrl
  });
}

class BibleDownloadService {
  
  static const String _treeUrl = 'https://api.github.com/repos/scrollmapper/bible_databases/git/trees/master?recursive=1';
  static const String _rawBaseUrl = 'https://raw.githubusercontent.com/scrollmapper/bible_databases/master';

  /// Fetch list of available JSON bibles from GitHub
  Future<List<GitHubBibleFile>> fetchAvailableBibles() async {
    try {
      final response = await http.get(Uri.parse(_treeUrl));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tree = data['tree'];

        final List<GitHubBibleFile> bibles = [];

        for (var item in tree) {
          final String path = item['path'];
          
          // Filter: only formats/json/ ending in .json
          if (path.startsWith('formats/json/') && path.endsWith('.json')) {
            // Extract name: formats/json/ACV.json -> ACV
            final filename = p.basename(path); // ACV.json
            final name = p.basenameWithoutExtension(filename); // ACV
            
            // Construct RAW download URL
            final downloadUrl = '$_rawBaseUrl/$path';
            
            bibles.add(GitHubBibleFile(
              name: name, 
              path: path, 
              downloadUrl: downloadUrl
            ));
          }
        }
        
        // Sort alphabetically
        bibles.sort((a, b) => a.name.compareTo(b.name));
        return bibles;

      } else {
        throw Exception('Failed to load Bible list: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching bibles: $e');
      throw Exception('Failed to connect to GitHub');
    }
  }

  /// Check if a bible is already downloaded to the local documents folder
  Future<bool> isBibleDownloaded(String name) async {
    final file = await _getLocalFile(name);
    return file.exists();
  }

  /// Download the bible JSON file
  /// Returns the local File path on success
  Future<String> downloadBible(GitHubBibleFile bible) async {
    final response = await http.get(Uri.parse(bible.downloadUrl));
    
    if (response.statusCode == 200) {
      final file = await _getLocalFile(bible.name);
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  }

  /// Helper to get local file reference
  Future<File> _getLocalFile(String name) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'LiteWorship', 'Bibles'));
    
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return File(p.join(dir.path, '$name.json'));
  }
}
