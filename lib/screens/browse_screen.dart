import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'upload_screen.dart';
import 'document_view_screen.dart';

class BrowseScreen extends StatefulWidget {
  final String userId;
  const BrowseScreen({super.key, required this.userId});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final AuthService _noteService = AuthService();
  final List<dynamic> _notes = [];
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMoreNotes();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        _loadMoreNotes();
      }
    });
  }

  Future<void> _loadMoreNotes() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final data = await _noteService.fetchAllNotes(
        page: _currentPage,
        size: 10,
      );
      debugPrint('📥 Fetched ${data.length} notes from page $_currentPage');

      if (!mounted) return;

      setState(() {
        _notes.addAll(data);
        _isLoading = false;
        _hasMore = data.length == 10;
        _currentPage++;
      });
    } catch (e) {
      debugPrint('❌ Failed to load notes: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) {
      _resetPagination();
      return _loadMoreNotes();
    }

    try {
      final data = await _noteService.search(q);
      if (!mounted) return;

      setState(() {
        _notes.clear();
        _notes.addAll(data);
        _hasMore = false;
      });
    } catch (e) {
      debugPrint('❌ Search failed: $e');
    }
  }

  void _resetPagination() {
    setState(() {
      _notes.clear();
      _currentPage = 0;
      _hasMore = true;
    });
  }

  Future<void> _navigateToUpload() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UploadScreen(userId: widget.userId)),
    );

    if (result == true) {
      _resetPagination();
      _loadMoreNotes();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Search notes',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _search,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: _notes.length,
              itemBuilder: (_, i) {
                final note = _notes[i];
                final fileUrl = note['fileUrl'] ?? '';
                final title = note['title'] ?? 'Untitled';
                final isImage =
                    fileUrl.toLowerCase().endsWith('.jpg') ||
                    fileUrl.toLowerCase().endsWith('.jpeg') ||
                    fileUrl.toLowerCase().endsWith('.png');

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => DocumentViewScreen(
                              fileUrl: fileUrl,
                              title: title,
                            ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isImage ? Icons.image : Icons.picture_as_pdf,
                            size: 40,
                            color: Colors.blue, // Updated to the primary color
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToUpload,
        child: const Icon(Icons.upload_file),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        // Floating action button color
      ),
    );
  }
}
