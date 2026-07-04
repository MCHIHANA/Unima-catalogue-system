import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final details = _LibraryPageDetails.forPage(page);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: Text(details.title), centerTitle: false),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoHero(details: details),
                  const SizedBox(height: 22),
                  ...details.sections.map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _InfoSection(section: section),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoHero extends StatelessWidget {
  final _LibraryPageDetails details;

  const _InfoHero({required this.details});

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
            child: Icon(details.icon, color: AppTheme.accentGold, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            details.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            details.subtitle,
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

class _InfoSection extends StatelessWidget {
  final _InfoSectionData section;

  const _InfoSection({required this.section});

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
                child: Icon(
                  section.icon,
                  color: AppTheme.primaryNavy,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
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
            section.body,
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

class _LibraryPageDetails {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_InfoSectionData> sections;

  const _LibraryPageDetails({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sections,
  });

  static _LibraryPageDetails forPage(LibraryInfoPage page) {
    switch (page) {
      case LibraryInfoPage.about:
        return const _LibraryPageDetails(
          title: 'About the Library',
          subtitle:
              'The University of Malawi Library supports learning, teaching, research, consultancy and knowledge preservation.',
          icon: Icons.info_rounded,
          sections: [
            _InfoSectionData(
              icon: Icons.account_balance_rounded,
              title: 'About Library',
              body:
                  'The University of Malawi Library supports the core and non-core functions of the university. The library is an integral part of the University mission, providing access to information resources, conservation and preservation of knowledge.',
            ),
            _InfoSectionData(
              icon: Icons.visibility_rounded,
              title: 'Vision',
              body:
                  'To be a library with a global perspective, providing an excellent academic environment for learning, teaching, research and collaboration.',
            ),
            _InfoSectionData(
              icon: Icons.flag_rounded,
              title: 'Mission',
              body:
                  'To provide quality information services and resources that support teaching, research, consultancy and innovation across the University community.',
            ),
            _InfoSectionData(
              icon: Icons.history_edu_rounded,
              title: 'History',
              body:
                  'The library continues to serve as a trusted academic resource hub for students, researchers, staff and the wider community, supporting access to scholarship and lifelong learning.',
            ),
          ],
        );
      case LibraryInfoPage.services:
        return const _LibraryPageDetails(
          title: 'Library Services',
          subtitle:
              'Support for discovery, access, research skills and productive study.',
          icon: Icons.design_services_rounded,
          sections: [
            _InfoSectionData(
              icon: Icons.library_books_rounded,
              title: 'Books, Journals and Digital Resources',
              body:
                  'The library offers access to books, journals and digital resources that provide essential information for study and research.',
            ),
            _InfoSectionData(
              icon: Icons.support_agent_rounded,
              title: 'Research Assistance',
              body:
                  'Students, researchers and staff can receive guidance on finding scholarly materials, using catalogue tools and improving research workflows.',
            ),
            _InfoSectionData(
              icon: Icons.groups_rounded,
              title: 'Training Workshops',
              body:
                  'Information literacy sessions help users develop practical skills for searching, evaluating and using academic information responsibly.',
            ),
            _InfoSectionData(
              icon: Icons.chair_rounded,
              title: 'Study Spaces',
              body:
                  'The library provides a comfortable academic environment for individual reading, collaboration and group study.',
            ),
          ],
        );
      case LibraryInfoPage.news:
        return const _LibraryPageDetails(
          title: 'Library News',
          subtitle:
              'Announcements, resource updates and notices from the University Library.',
          icon: Icons.newspaper_rounded,
          sections: [
            _InfoSectionData(
              icon: Icons.campaign_rounded,
              title: 'Announcements',
              body:
                  'Important library notices, service changes, new collections and digital resource updates appear here.',
            ),
            _InfoSectionData(
              icon: Icons.new_releases_rounded,
              title: 'New Resources',
              body:
                  'Recently added books, journals and e-resources are highlighted to help users discover current academic materials.',
            ),
          ],
        );
      case LibraryInfoPage.events:
        return const _LibraryPageDetails(
          title: 'Library Events',
          subtitle: 'Workshops, orientations and academic support sessions.',
          icon: Icons.event_rounded,
          sections: [
            _InfoSectionData(
              icon: Icons.school_rounded,
              title: 'Orientations',
              body:
                  'Library orientation sessions introduce students to catalogue search, borrowing guidance, digital resources and research support.',
            ),
            _InfoSectionData(
              icon: Icons.edit_calendar_rounded,
              title: 'Workshops',
              body:
                  'Training events include information literacy, referencing, database searching and research discovery sessions.',
            ),
          ],
        );
      case LibraryInfoPage.locations:
        return const _LibraryPageDetails(
          title: 'Contact and Locations',
          subtitle:
              'Find library spaces, contact points and opening information.',
          icon: Icons.location_on_rounded,
          sections: [
            _InfoSectionData(
              icon: Icons.place_rounded,
              title: 'Library Locations',
              body:
                  'Use this section to identify University Library service points, collection areas and reading spaces.',
            ),
            _InfoSectionData(
              icon: Icons.schedule_rounded,
              title: 'Opening Hours',
              body:
                  'Opening hours and service availability should be confirmed with current library notices during holidays, examination periods and special events.',
            ),
            _InfoSectionData(
              icon: Icons.contact_mail_rounded,
              title: 'Contact',
              body:
                  'Contact the library for help with catalogue access, research support, reserve materials and general information services.',
            ),
          ],
        );
      case LibraryInfoPage.help:
        return const _LibraryPageDetails(
          title: 'Help and FAQs',
          subtitle:
              'Guidance for catalogue use, library conduct and support questions.',
          icon: Icons.help_rounded,
          sections: [
            _InfoSectionData(
              icon: Icons.search_rounded,
              title: 'Using the Catalogue',
              body:
                  'Search by title, author, course, category or ISBN. Use school filters to narrow the collection to a specific academic area.',
            ),
            _InfoSectionData(
              icon: Icons.rule_rounded,
              title: 'Library Rules',
              body:
                  'Users are expected to respect library spaces, handle materials responsibly and follow borrowing, reserve and study-area guidance.',
            ),
            _InfoSectionData(
              icon: Icons.question_answer_rounded,
              title: 'FAQs',
              body:
                  'Common questions about finding resources, accessing e-books and identifying availability status can be answered through library support.',
            ),
          ],
        );
      case LibraryInfoPage.settings:
        return const _LibraryPageDetails(
          title: 'Settings',
          subtitle: 'Application preferences and user support settings.',
          icon: Icons.settings_rounded,
          sections: [
            _InfoSectionData(
              icon: Icons.palette_rounded,
              title: 'Appearance',
              body:
                  'The app uses a modern Material 3 interface based on the University of Malawi colour palette for clarity and consistency.',
            ),
            _InfoSectionData(
              icon: Icons.accessibility_new_rounded,
              title: 'Accessibility',
              body:
                  'The interface supports readable contrast, large tap targets and platform text scaling where supported by the device.',
            ),
          ],
        );
    }
  }
}

class _InfoSectionData {
  final IconData icon;
  final String title;
  final String body;

  const _InfoSectionData({
    required this.icon,
    required this.title,
    required this.body,
  });
}
