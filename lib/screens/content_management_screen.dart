import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/content_item.dart';
import '../services/content_service.dart';
import '../widgets/main_layout.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final ContentService _svc = ContentService();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1100;
    final hPad = isDesktop ? 60.0 : 20.0;

    return MainLayout(
      currentRoute: 'ContentManagement',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_note_rounded,
                        color: AppTheme.accentGold, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Content Management',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textDark),
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 3),
                        Text(
                            'Edit news, events and library information pages',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textGrey),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              labelColor: AppTheme.primaryNavy,
              unselectedLabelColor: AppTheme.textGrey,
              indicatorColor: AppTheme.accentGold,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'News'),
                Tab(text: 'Events'),
                Tab(text: 'About'),
                Tab(text: 'Services'),
                Tab(text: 'Help & FAQs'),
                Tab(text: 'Location'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _ListSectionTab(section: 'news', svc: _svc, hPad: hPad),
                _EventsSectionTab(svc: _svc, hPad: hPad),
                _PageSectionTab(section: 'about', svc: _svc, hPad: hPad),
                _PageSectionTab(section: 'services', svc: _svc, hPad: hPad),
                _PageSectionTab(section: 'help', svc: _svc, hPad: hPad),
                _PageSectionTab(section: 'location', svc: _svc, hPad: hPad),
                _PageSectionTab(section: 'settings', svc: _svc, hPad: hPad),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── News list tab ───────────────────────────────────────────────────────────

class _ListSectionTab extends StatelessWidget {
  final String section;
  final ContentService svc;
  final double hPad;

  const _ListSectionTab(
      {required this.section, required this.svc, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item',
            style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () => _showItemDialog(context, svc, section, null),
      ),
      body: StreamBuilder<List<ContentItem>>(
        stream: svc.getSectionAdmin(section),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _EmptyState(
              label: 'No $section items yet.',
              icon: Icons.newspaper_rounded,
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 100),
            itemCount: items.length,
            itemBuilder: (context, i) =>
                _ContentItemRow(item: items[i], svc: svc, section: section),
          );
        },
      ),
    );
  }
}

// ─── Events tab ──────────────────────────────────────────────────────────────

class _EventsSectionTab extends StatelessWidget {
  final ContentService svc;
  final double hPad;

  const _EventsSectionTab({required this.svc, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Event',
            style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () => _showEventDialog(context, svc, null),
      ),
      body: StreamBuilder<List<ContentItem>>(
        stream: svc.getSectionAdmin('events'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const _EmptyState(
              label: 'No events yet.',
              icon: Icons.event_rounded,
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 100),
            itemCount: items.length,
            itemBuilder: (context, i) =>
                _ContentItemRow(item: items[i], svc: svc, section: 'events', isEvent: true),
          );
        },
      ),
    );
  }
}

// ─── Page section tab (about, services, help, location, settings) ────────────

class _PageSectionTab extends StatefulWidget {
  final String section;
  final ContentService svc;
  final double hPad;

  const _PageSectionTab(
      {required this.section, required this.svc, required this.hPad});

  @override
  State<_PageSectionTab> createState() => _PageSectionTabState();
}

class _PageSectionTabState extends State<_PageSectionTab> {
  final _subtitleCtrl = TextEditingController();
  final List<_SubSectionEditor> _editors = [];
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _subtitleCtrl.dispose();
    for (final e in _editors) {
      e.titleCtrl.dispose();
      e.bodyCtrl.dispose();
    }
    super.dispose();
  }

  void _initFromPage(ContentPage page) {
    if (_initialized) return;
    _initialized = true;
    _subtitleCtrl.text = page.subtitle;
    _editors.clear();
    for (final s in page.sections) {
      _editors.add(_SubSectionEditor(
        titleCtrl: TextEditingController(text: s.title),
        bodyCtrl: TextEditingController(text: s.body),
      ));
    }
  }

  void _addSection() {
    setState(() {
      _editors.add(_SubSectionEditor(
        titleCtrl: TextEditingController(),
        bodyCtrl: TextEditingController(),
      ));
    });
  }

  void _removeSection(int i) {
    setState(() {
      _editors[i].titleCtrl.dispose();
      _editors[i].bodyCtrl.dispose();
      _editors.removeAt(i);
    });
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final sections = _editors
          .map((e) => ContentSection(
              title: e.titleCtrl.text.trim(),
              body: e.bodyCtrl.text.trim()))
          .where((s) => s.title.isNotEmpty || s.body.isNotEmpty)
          .toList();
      final page = ContentPage(
        section: widget.section,
        subtitle: _subtitleCtrl.text.trim(),
        sections: sections,
      );
      await widget.svc.savePage(page);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Saved successfully',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ContentPage?>(
      stream: widget.svc.getPage(widget.section),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_initialized) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && !_initialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _initFromPage(snapshot.data!));
          });
        }
        return SingleChildScrollView(
          padding:
              EdgeInsets.fromLTRB(widget.hPad, 24, widget.hPad, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Page subtitle / description'),
              const SizedBox(height: 8),
              _textField(_subtitleCtrl, 'Shown below the page title...', maxLines: 2),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Text('Sections',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark)),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _addSection,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add section'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._editors.asMap().entries.map((entry) {
                final i = entry.key;
                final ed = entry.value;
                return _SectionEditorCard(
                  index: i,
                  editor: ed,
                  onRemove: () => _removeSection(i),
                );
              }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _save,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded, size: 20),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Section editor card ─────────────────────────────────────────────────────

class _SectionEditorCard extends StatelessWidget {
  final int index;
  final _SubSectionEditor editor;
  final VoidCallback onRemove;

  const _SectionEditorCard(
      {required this.index, required this.editor, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Section ${index + 1}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryNavy,
                      letterSpacing: 0.4)),
            ),
            const Spacer(),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 20, color: Colors.red),
              tooltip: 'Remove section',
            ),
          ]),
          const SizedBox(height: 12),
          _fieldLabel('Title'),
          const SizedBox(height: 6),
          _textField(editor.titleCtrl, 'e.g. Library Services...'),
          const SizedBox(height: 14),
          _fieldLabel('Body'),
          const SizedBox(height: 6),
          _textField(editor.bodyCtrl, 'Write the content here...', maxLines: 5),
        ],
      ),
    );
  }
}

// ─── Content item row (news / events) ────────────────────────────────────────

class _ContentItemRow extends StatelessWidget {
  final ContentItem item;
  final ContentService svc;
  final String section;
  final bool isEvent;

  const _ContentItemRow({
    required this.item,
    required this.svc,
    required this.section,
    this.isEvent = false,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(item.title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          _statusBadge(item.isActive),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 18,
                color: AppTheme.primaryNavy),
            tooltip: 'Edit',
            onPressed: () => isEvent
                ? _showEventDialog(context, svc, item)
                : _showItemDialog(context, svc, section, item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, svc, item),
          ),
        ]),
        if (isEvent && item.eventDate != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.calendar_today_rounded,
                size: 13, color: AppTheme.accentGold),
            const SizedBox(width: 6),
            Text(df.format(item.eventDate!),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGold)),
            if (item.eventEndDate != null)
              Text(' — ${df.format(item.eventEndDate!)}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textGrey)),
          ]),
        ],
        const SizedBox(height: 8),
        Text(item.body,
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textGrey,
                fontWeight: FontWeight.w500),
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _statusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? 'ACTIVE' : 'HIDDEN',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: active ? Colors.green.shade700 : Colors.red,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─── Add / Edit news item dialog ──────────────────────────────────────────────

Future<void> _showItemDialog(BuildContext context, ContentService svc,
    String section, ContentItem? existing) async {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final bodyCtrl = TextEditingController(text: existing?.body ?? '');
  bool isActive = existing?.isActive ?? true;
  bool saving = false;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          existing == null ? 'Add ${_sectionLabel(section)} Item' : 'Edit Item',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Title *'),
                const SizedBox(height: 6),
                _textField(titleCtrl, 'e.g. New Book Arrivals'),
                const SizedBox(height: 16),
                _fieldLabel('Body *'),
                const SizedBox(height: 6),
                _textField(bodyCtrl, 'Write the announcement or article body here...', maxLines: 5),
                const SizedBox(height: 16),
                Row(children: [
                  Switch(
                    value: isActive,
                    activeColor: AppTheme.primaryNavy,
                    onChanged: (v) => setD(() => isActive = v),
                  ),
                  const SizedBox(width: 8),
                  Text(isActive ? 'Visible to users' : 'Hidden from users',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: saving
                ? null
                : () async {
                    if (titleCtrl.text.trim().isEmpty ||
                        bodyCtrl.text.trim().isEmpty) return;
                    setD(() => saving = true);
                    try {
                      if (existing == null) {
                        await svc.addItem(ContentItem(
                          section: section,
                          title: titleCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                          isActive: isActive,
                        ));
                      } else {
                        await svc.updateItem(existing.copyWith(
                          title: titleCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                          isActive: isActive,
                        ));
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      setD(() => saving = false);
                    }
                  },
            icon: saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_rounded, size: 16),
            label: Text(existing == null ? 'Add' : 'Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    ),
  );
  titleCtrl.dispose();
  bodyCtrl.dispose();
}

// ─── Add / Edit event dialog ──────────────────────────────────────────────────

Future<void> _showEventDialog(
    BuildContext context, ContentService svc, ContentItem? existing) async {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final bodyCtrl = TextEditingController(text: existing?.body ?? '');
  bool isActive = existing?.isActive ?? true;
  DateTime? eventDate = existing?.eventDate;
  DateTime? eventEndDate = existing?.eventEndDate;
  bool saving = false;
  final df = DateFormat('d MMM yyyy');

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          existing == null ? 'Add Event' : 'Edit Event',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Event Title *'),
                const SizedBox(height: 6),
                _textField(titleCtrl, 'e.g. Library Orientation 2026'),
                const SizedBox(height: 16),
                _fieldLabel('Description / Message *'),
                const SizedBox(height: 6),
                _textField(bodyCtrl, 'Describe the event, venue, requirements...', maxLines: 5),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Start Date'),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: eventDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) setD(() => eventDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Row(children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16,
                                  color: AppTheme.primaryNavy),
                              const SizedBox(width: 8),
                              Text(
                                eventDate != null
                                    ? df.format(eventDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: eventDate != null
                                      ? AppTheme.textDark
                                      : AppTheme.textGrey,
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('End Date (opt.)'),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: eventEndDate ?? eventDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) setD(() => eventEndDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Row(children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16,
                                  color: AppTheme.textGrey),
                              const SizedBox(width: 8),
                              Text(
                                eventEndDate != null
                                    ? df.format(eventEndDate!)
                                    : 'Optional',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: eventEndDate != null
                                      ? AppTheme.textDark
                                      : AppTheme.textGrey,
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Switch(
                    value: isActive,
                    activeColor: AppTheme.primaryNavy,
                    onChanged: (v) => setD(() => isActive = v),
                  ),
                  const SizedBox(width: 8),
                  Text(isActive ? 'Visible to users' : 'Hidden',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: saving
                ? null
                : () async {
                    if (titleCtrl.text.trim().isEmpty ||
                        bodyCtrl.text.trim().isEmpty) return;
                    setD(() => saving = true);
                    try {
                      if (existing == null) {
                        await svc.addItem(ContentItem(
                          section: 'events',
                          title: titleCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                          eventDate: eventDate,
                          eventEndDate: eventEndDate,
                          isActive: isActive,
                        ));
                      } else {
                        await svc.updateItem(existing.copyWith(
                          title: titleCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                          eventDate: eventDate,
                          eventEndDate: eventEndDate,
                          isActive: isActive,
                        ));
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      setD(() => saving = false);
                    }
                  },
            icon: saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_rounded, size: 16),
            label: Text(existing == null ? 'Add Event' : 'Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    ),
  );
  titleCtrl.dispose();
  bodyCtrl.dispose();
}

// ─── Delete confirm ───────────────────────────────────────────────────────────

Future<void> _confirmDelete(
    BuildContext context, ContentService svc, ContentItem item) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
        SizedBox(width: 10),
        Text('Delete Item',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
      ]),
      content: Text('Delete "${item.title}"? This cannot be undone.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed == true && item.id != null) {
    await svc.deleteItem(item.id!);
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label;
  final IconData icon;

  const _EmptyState({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textGrey)),
          const SizedBox(height: 8),
          const Text('Use the + button to add content.',
              style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SubSectionEditor {
  final TextEditingController titleCtrl;
  final TextEditingController bodyCtrl;

  _SubSectionEditor({required this.titleCtrl, required this.bodyCtrl});
}

Widget _fieldLabel(String label) {
  return Text(label,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppTheme.textGrey,
          letterSpacing: 0.5));
}

Widget _textField(TextEditingController ctrl, String hint,
    {int maxLines = 1}) {
  return TextField(
    controller: ctrl,
    maxLines: maxLines,
    style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: AppTheme.textGrey.withValues(alpha: 0.5), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2)),
    ),
  );
}

String _sectionLabel(String section) {
  switch (section) {
    case 'news':
      return 'News';
    case 'events':
      return 'Event';
    default:
      return section;
  }
}
