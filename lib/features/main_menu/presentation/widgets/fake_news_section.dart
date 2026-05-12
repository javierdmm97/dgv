import 'package:flutter/material.dart';

import 'package:dgv/core/constants/dgt_strings.dart';
import 'package:dgv/core/theme/dgt_colors.dart';

/// A horizontal scrollable section showing a preview of fake news articles.
///
/// Displays a row of [_ArticlePreviewTile] cards built from [articles], plus
/// a "Ver todo" button that calls [onViewAll].
///
/// Requirements: 8.12
class FakeNewsSection extends StatelessWidget {
  const FakeNewsSection({
    super.key,
    required this.articles,
    required this.onViewAll,
  });

  final List<FakeNewsArticle> articles;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(onViewAll: onViewAll),
        const SizedBox(height: 8),
        _ArticleList(articles: articles),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DGTStrings.actualidadDGV,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DGTColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'Ver todo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DGTColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleList extends StatelessWidget {
  const _ArticleList({required this.articles});

  final List<FakeNewsArticle> articles;

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(child: Text('No hay noticias')),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: articles.length,
        itemBuilder: (context, index) =>
            _ArticlePreviewTile(article: articles[index]),
      ),
    );
  }
}

class _ArticlePreviewTile extends StatelessWidget {
  const _ArticlePreviewTile({required this.article});

  final FakeNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: DGTColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            article.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: DGTColors.textPrimary,
            ),
          ),
          Text(
            article.date,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: DGTColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
