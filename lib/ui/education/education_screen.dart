import 'package:flutter/material.dart';
import 'package:mhad/data/educational_content.dart';

class EducationScreen extends StatefulWidget {
  /// If set, only show sections matching these IDs (deep-link from wizard Help).
  final List<String>? filterIds;

  const EducationScreen({this.filterIds, super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  EducationCategory? _selectedCategory;
  String _query = '';

  List<EducationSection> get _filteredSections {
    // When opened from a wizard Help button, show only the linked sections
    if (widget.filterIds != null && widget.filterIds!.isNotEmpty) {
      final ids = widget.filterIds!.toSet();
      return allEducationSections.where((s) => ids.contains(s.id)).toList();
    }

    var sections = allEducationSections;

    if (_selectedCategory != null) {
      sections = sections
          .where((s) => s.category == _selectedCategory)
          .toList();
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      sections = sections
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.content.toLowerCase().contains(q))
          .toList();
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final isFiltered =
        widget.filterIds != null && widget.filterIds!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFiltered ? 'Help' : 'Education & Resources'),
        actions: [
          if (!isFiltered) ...[
            if (_query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear search',
                onPressed: () => setState(() => _query = ''),
              ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () async {
                final result = await showSearch(
                  context: context,
                  delegate: _EducationSearchDelegate(),
                  query: _query,
                );
                if (result != null && mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _SectionDetailScreen(section: result),
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (!isFiltered)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  isDense: true,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<EducationCategory?>(
                    value: _selectedCategory,
                    isExpanded: true,
                    isDense: true,
                    items: [
                      const DropdownMenuItem<EducationCategory?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...EducationCategory.values.map(
                        (cat) => DropdownMenuItem<EducationCategory?>(
                          value: cat,
                          child: Text(cat.displayName),
                        ),
                      ),
                    ],
                    onChanged: (cat) =>
                        setState(() => _selectedCategory = cat),
                  ),
                ),
              ),
            ),
          Expanded(
            child: _filteredSections.isEmpty
                ? const Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredSections.length,
                    itemBuilder: (context, i) =>
                        _SectionTile(section: _filteredSections[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final EducationSection section;
  const _SectionTile({required this.section});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${section.category.displayName}: ${section.title}',
      child: Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _SectionDetailScreen(section: section),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryBadge(category: section.category),
                  const Spacer(),
                  ExcludeSemantics(
                    child: Icon(Icons.chevron_right, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                section.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                section.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final EducationCategory category;
  const _CategoryBadge({required this.category});

  Color _color(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (category) {
      case EducationCategory.intro:
        return cs.primary;
      case EducationCategory.faq:
        return cs.secondary;
      case EducationCategory.combined:
        return cs.tertiary;
      case EducationCategory.declaration:
        return cs.primary;
      case EducationCategory.poa:
        return cs.secondary;
      case EducationCategory.glossary:
        return cs.onSurfaceVariant;
      case EducationCategory.supplementary:
        return cs.tertiary;
      case EducationCategory.checklist:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        category.displayName,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SectionDetailScreen extends StatelessWidget {
  final EducationSection section;
  const _SectionDetailScreen({required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(section.category.displayName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryBadge(category: section.category),
            const SizedBox(height: 12),
            Text(
              section.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              section.content,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Questions? Contact PA Protection & Advocacy: 1-800-692-7443',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _EducationSearchDelegate extends SearchDelegate<EducationSection?> {
  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Type to search educational content...'),
      );
    }
    final q = query.toLowerCase();
    final results = allEducationSections
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.content.toLowerCase().contains(q))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text('No results for "$query"'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () => close(context, results[i]),
        child: _SectionTile(section: results[i]),
      ),
    );
  }
}
