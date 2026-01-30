
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song_model.dart' as model;
import '../providers/user_content_provider.dart';  // userSongServiceProvider
import '../config/theme.dart';

class SongEditorScreen extends ConsumerStatefulWidget {
  final model.SongModel? existingSong;
  
  const SongEditorScreen({super.key, this.existingSong});

  @override
  ConsumerState<SongEditorScreen> createState() => _SongEditorScreenState();
}

class _SongEditorScreenState extends ConsumerState<SongEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _authorController;
  late TextEditingController _copyrightController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingSong?.title ?? '');
    _contentController = TextEditingController(text: widget.existingSong?.lyrics ?? '');
    _authorController = TextEditingController(text: widget.existingSong?.author ?? '');
    _copyrightController = TextEditingController(text: widget.existingSong?.copyright ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _copyrightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        final service = ref.read(userSongServiceProvider);
        
        final newSong = model.SongModel(
          uuid: widget.existingSong?.uuid, // If null, service will generate
          title: _titleController.text.trim(),
          lyrics: _contentController.text,
          author: _authorController.text.trim().isEmpty ? null : _authorController.text.trim(),
          copyright: _copyrightController.text.trim().isEmpty ? null : _copyrightController.text.trim(),
          source: 'local', // Explicitly user content
        );

        await service.saveSong(newSong);

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Song saved!'), backgroundColor: Colors.green),
           );
           Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
           );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LWColors.background,
      appBar: AppBar(
        title: Text(widget.existingSong == null ? "New Song" : "Edit Song"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
            tooltip: "Save Song",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TITLE
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: LWColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: LWColors.surface,
                ),
                validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              
              // CONTENT
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  style: const TextStyle(color: LWColors.textPrimary, fontFamily: 'monospace'),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Lyrics / Content',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: LWColors.surface,
                    alignLabelWithHint: true,
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Content is required' : null,
                ),
              ),
              const SizedBox(height: 16),
              
              // META
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _authorController,
                      style: const TextStyle(color: LWColors.textSecondary),
                      decoration: const InputDecoration(
                        labelText: 'Author (Optional)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: LWColors.surface,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _copyrightController,
                      style: const TextStyle(color: LWColors.textSecondary),
                      decoration: const InputDecoration(
                        labelText: 'Copyright (Optional)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: LWColors.surface,
                         isDense: true,
                      ),
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
}
