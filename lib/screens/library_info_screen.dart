import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/content_item.dart';
import '../services/content_service.dart';

enum LibraryInfoPage {
  about,
  services,
  news,
  events,
  locations,
  help,
  settings,
}

class LibraryInfoScreen extends StatelessWidget {
  final LibraryInfoPage page;

  const LibraryInfoScreen({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final meta = _PageMeta.forPage(page);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: Text(meta.title), centerTitle: false),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoHero(meta: meta),
                  const SizedBox(height: 22),
                  _PageBody(page: page, meta: meta),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero banner ────────────────────────────────────────────────────────────

class _InfoHero extends StatelessWidget {
  final _PageMeta meta;

  const _InfoHero({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(meta.icon, color: AppTheme.accentGold, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            meta.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            meta.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dynamic page body ──────────────────────────────────────────────────────

class _PageBody extends StatelessWidget {
  final LibraryInfoPage page;
  final _PageMeta meta;

  const _PageBody({required this.page, required this.meta});

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case LibraryInfoPage.news:
        return _LiveListSection(section: 'news', meta: meta);
      case LibraryInfoPage.events:
        return _LiveEventsSection(meta: meta);
      case LibraryInfoPage.about:
        return _LivePageSection(section: 'about', meta: meta);
      case LibraryInfoPage.services:
        return _LivePageSection(section: 'services', meta: meta);
      case LibraryInfoPage.help:
        return _LivePageSection(section: 'help', meta: meta);
      case LibraryInfoPage.locations:
        return _LocationSection(meta: meta);
      case LibraryInfoPage.settings:
        return _LivePageSection(section: 'settings', meta: meta);
    }
  }
}

// ─── News list (stream) ─────────────────────────────────────────────────────

class _LiveListSection extends StatelessWidget {
  final String section;
  final _PageMeta meta;

  const _LiveListSection({required this.section, required this.meta});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ContentItem>>(
      stream: ContentService().getSection(section),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Column(
            children: meta.fallbackSections
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _InfoCard(title: s.title, body: s.body),
                    ))
                .toList(),
          );
        }
        return Column(
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _InfoCard(title: item.title, body: item.body),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ─── Events list (with dates) ───────────────────────────────────────────────

class _LiveEventsSection extends StatelessWidget {
  final _PageMeta meta;

  const _LiveEventsSection({required this.meta});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ContentItem>>(
      stream: ContentService().getSection('events'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Column(
            children: meta.fallbackSections
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _InfoCard(title: s.title, body: s.body),
                    ))
                .toList(),
          );
        }
        return Column(
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _EventCard(item: item),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ─── Event card with date badge ──────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final ContentItem item;

  const _EventCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMM yyyy');
    final hasDate = item.eventDate != null;
    final isUpcoming =
        hasDate && item.eventDate!.isAfter(DateTime.now());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUpcoming
              ? AppTheme.accentGold.withValues(alpha: 0.4)
              : AppTheme.primaryNavy.withValues(alpha: 0.06),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date band
          if (hasDate)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isUpcoming
                    ? AppTheme.accentGold.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: isUpcoming ? AppTheme.accentGold : AppTheme.textGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormatter.format(item.eventDate!),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isUpcoming
                          ? AppTheme.accentGold
                          : AppTheme.textGrey,
                    ),
                  ),
                  if (item.eventEndDate != null) ...[
                    Text(
                      ' — ${dateFormatter.format(item.eventEndDate!)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isUpcoming
                            ? AppTheme.accentGold
                            : AppTheme.textGrey,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? AppTheme.accentGold.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isUpcoming ? 'UPCOMING' : 'PAST',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isUpcoming
                            ? AppTheme.accentGold
                            : AppTheme.textGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: AppTheme.primaryNavy,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.body,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page-based sections (about, services, help, settings) ──────────────────

class _LivePageSection extends StatelessWidget {
  final String section;
  final _PageMeta meta;

  const _LivePageSection({required this.section, required this.meta});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ContentPage?>(
      stream: ContentService().getPage(section),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final page = snapshot.data;
        if (page == null || page.sections.isEmpty) {
          // Fallback to static content
          return Column(
            children: meta.fallbackSections
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _InfoCard(title: s.title, body: s.body),
                    ))
                .toList(),
          );
        }
        return Column(
          children: page.sections
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _InfoCard(title: s.title, body: s.body),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ─── Location section (static + editable via page) ──────────────────────────

class _LocationSection extends StatelessWidget {
  final _PageMeta meta;

  const _LocationSection({required this.meta});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ContentPage?>(
      stream: ContentService().getPage('location'),
      builder: (context, snapshot) {
        final page = snapshot.data;

        Widget liveContent;
        if (page != null && page.sections.isNotEmpty) {
          liveContent = Column(
            children: page.sections
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _InfoCard(title: s.title, body: s.body),
                    ))
                .toList(),
          );
        } else {
          liveContent = Column(
            children: meta.fallbackSections
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _InfoCard(title: s.title, body: s.body),
                    ))
                .toList(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static map-style address card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryNavy, Color(0xFF1E2A8A)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppTheme.accentGold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'University of Malawi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Zomba, Malawi',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Chancellor College Campus',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.map_rounded,
                    color: AppTheme.accentGold,
                    size: 28,
                  ),
                ],
              ),
            ),
            liveContent,
          ],
        );
      },
    );
  }
}

// ─── Reusable info card ──────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.06)),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryNavy, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Static metadata + fallback content ─────────────────────────────────────

class _PageMeta {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_FallbackSection> fallbackSections;

  const _PageMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.fallbackSections,
  });

  static _PageMeta forPage(LibraryInfoPage page) {
    switch (page) {
      case LibraryInfoPage.about:
        return const _PageMeta(
          title: 'About the Library',
          subtitle:
              'The University of Malawi Library supports learning, teaching, research, consultancy and knowledge preservation.',
          icon: Icons.info_rounded,
          fallbackSections: [
            _FallbackSection(
              title: 'About Library',
              body:
                  'The University of Malawi Library supports the core and non-core functions of the university. The library is an integral part of the University mission, providing access to information resources, conservation and preservation of knowledge.',
            ),
            _FallbackSection(
              title: 'Vision',
              body:
                  'To be a library with a global perspective, providing an excellent academic environment for learning, teaching, research and collaboration.',
            ),
            _FallbackSection(
              title: 'Mission',
              body:
                  'To provide quality information services and resources that support teaching, research, consultancy and innovation across the University community.',
            ),
          ],
        );
      case LibraryInfoPage.services:
        return const _PageMeta(
          title: 'Library Services',
          subtitle: 'Support for discovery, access, research skills and productive study.',
          icon: Icons.design_services_rounded,
          fallbackSections: [
            _FallbackSection(
              title: 'Books, Journals and Digital Resources',
              body:
                  'The library offers access to books, journals and digital resources that provide essential information for study and research.',
            ),
            _FallbackSection(
              title: 'Research Assistance',
              body:
                  'Students, researchers and staff can receive guidance on finding scholarly materials, using catalogue tools and improving research workflows.',
            ),
            _FallbackSection(
              title: 'Training Workshops',
              body:
                  'Information literacy sessions help users develop practical skills for searching, evaluating and using academic information responsibly.',
            ),
          ],
        );
      case LibraryInfoPage.news:
        return const _PageMeta(
          title: 'Library News',
          subtitle:
              'Announcements, resource updates and notices from the University Library.',
          icon: Icons.newspaper_rounded,
          fallbackSections: [
            _FallbackSection(
              title: 'Announcements',
              body:
                  'Important library notices, service changes, new collections and digital resource updates appear here.',
            ),
            _FallbackSection(
              title: 'New Resources',
              body:
                  'Recently added books, journals and e-resources are highlighted to help users discover current academic materials.',
            ),
          ],
        );
      case LibraryInfoPage.events:
        return const _PageMeta(
          title: 'Library Events',
          subtitle: 'Workshops, orientations and academic support sessions.',
          icon: Icons.event_rounded,
          fallbackSections: [
            _FallbackSection(
              title: 'Orientations',
              body:
                  'Library orientation sessions introduce students to catalogue search, borrowing guidance, digital resources and research support.',
            ),
            _FallbackSection(
              title: 'Workshops',
              body:
                  'Training events include information literacy, referencing, database searching and research discovery sessions.',
            ),
          ],
        );
      case LibraryInfoPage.locations:
        return const _PageMeta(
          title: 'Contact and Locations',
          subtitle: 'Find library spaces, contact points and opening information.',
          icon: Icons.location_on_rounded,
          fallbackSections: [
            _FallbackSection(
              title: 'Main Library — Zomba Campus',
              body:
                  'University of Malawi, Zomba, Malawi. The main library is located at the Chancellor College campus and serves as the central hub for all library services.',
            ),
            _FallbackSection(
              title: 'Opening Hours',
              body:
                  'Monday – Friday: 08:00 – 20:00\nSaturday: 08:00 – 16:00\nSunday: 10:00 – 14:00\n\nOpening hours may vary during holidays, examinations and special events.',
            ),
            _FallbackSection(
              title: 'Contact',
              body:
                  'For enquiries, catalogue access, research support or reserve materials, contact the library service desk.\n\nUniversity of Malawi, P.O. Box 280, Zomba, Malawi.',
            ),
          ],
        );
      case LibraryInfoPage.help:
        return const _PageMeta(
          title: 'Help and FAQs',
          subtitle: 'Guidance for catalogue use, library conduct and support questions.',
          icon: Icons.help_rounded,
          fallbackSections: [
            _FallbackSection(
              title: 'Using the Catalogue',
              body:
                  'Search by title, author, course, category or ISBN. Use school filters to narrow the collection to a specific academic area.',
            ),
            _FallbackSection(
              title: 'Library Rules',
              body:
                  'Users are expected to respect library spaces, handle materials responsibly and follow borrowing, reserve and study-area guidance.',
            ),
            _FallbackSection(
              title: 'FAQs',
              body:
                  'Common questions about finding resources, accessing e-books and identifying availability status can be answered through library support.',
            ),
          ],
        );
      case LibraryInfoPage.settings:
        return const _PageMeta(
          title: 'Settings',
          subtitle: 'Application preferences and user support settings.',
          icon: Icons.settings_rounded,
          fallbackSections: [
            _FallbackSection(
              title: 'Appearance',
              body:
                  'The app uses a modern Material 3 interface based on the University of Malawi colour palette for clarity and consistency.',
            ),
            _FallbackSection(
              title: 'Accessibility',
              body:
                  'The interface supports readable contrast, large tap targets and platform text scaling where supported by the device.',
            ),
          ],
        );
    }
  }
}

class _FallbackSection {
  final String title;
  final String body;

  const _FallbackSection({required this.title, required this.body});
}
