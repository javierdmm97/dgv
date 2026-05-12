import 'package:flutter/material.dart';

import 'package:dgv/core/constants/dgt_strings.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/main_menu/presentation/fake_news_detail_screen.dart';

/// Full-screen list of satirical DGT fake news articles.
///
/// Displays [kFakeNewsArticles] in a [ListView.builder]. Tapping an article
/// navigates to [FakeNewsDetailScreen]. An empty list shows a centred
/// placeholder message.
///
/// Requirements: 9.1, 9.2, 9.4, 9.5
class FakeNewsScreen extends StatelessWidget {
  const FakeNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
        title: Text(
          DGTStrings.actualidadDGV,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: DGTColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: DGTColors.textOnPrimary),
      ),
      body: kFakeNewsArticles.isEmpty
          ? const _EmptyState()
          : const _ArticleListView(articles: kFakeNewsArticles),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No hay noticias'));
  }
}

class _ArticleListView extends StatelessWidget {
  const _ArticleListView({required this.articles});

  final List<FakeNewsArticle> articles;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: articles.length,
      itemBuilder: (context, index) => _ArticleTile(article: articles[index]),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});

  final FakeNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: article.title,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: DGTColors.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => FakeNewsDetailScreen(article: article),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ArticleThumbnail(imagePath: article.imagePath),
                const SizedBox(width: 12),
                Expanded(child: _ArticleTileContent(article: article)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleThumbnail extends StatelessWidget {
  const _ArticleThumbnail({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: DGTColors.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: imagePath.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _PlaceholderIcon(),
              ),
            )
          : const _PlaceholderIcon(),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.article_outlined,
      color: DGTColors.primary,
      size: 32,
      semanticLabel: 'Artículo',
    );
  }
}

class _ArticleTileContent extends StatelessWidget {
  const _ArticleTileContent({required this.article});

  final FakeNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: DGTColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          article.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: DGTColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          article.date,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: DGTColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
