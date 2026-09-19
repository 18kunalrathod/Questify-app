import 'package:flutter/material.dart';
import '../../../shared/widgets/ambient_glow_background.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../documents/presentation/documents_screen.dart';
import '../../progress_photos/presentation/progress_photos_screen.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;

    return AmbientGlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('The Ledger'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: accent,
            unselectedLabelColor: mutedColor,
            indicatorColor: accent,
            tabs: const [
              Tab(text: 'Notes'),
              Tab(text: 'Documents'),
              Tab(text: 'Photos'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            NotesTab(),
            DocumentsTab(),
            PhotosTab(),
          ],
        ),
      ),
    );
  }
}