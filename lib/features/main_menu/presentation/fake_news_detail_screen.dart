import 'package:flutter/material.dart';

import 'package:dgv/core/constants/dgt_strings.dart';
import 'package:dgv/core/theme/dgt_colors.dart';

/// Full-screen detail view for a single [FakeNewsArticle].
///
/// Displays the article with a DGT-styled blue header containing the title
/// and date, followed by the full body text. Includes a back button in the
/// [AppBar].
///
/// Requirements: 9.2, 9.3, 9.4, 9.5
class FakeNewsDetailScreen extends StatelessWidget {
  const FakeNewsDetailScreen({super.key, required this.article});

  final FakeNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DGTColors.background,
      body: CustomScrollView(
        slivers: [
          _DGTSliverAppBar(article: article),
          SliverToBoxAdapter(child: _ArticleBody(article: article)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _DGTSliverAppBar extends StatelessWidget {
  const _DGTSliverAppBar({required this.article});

  final FakeNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: DGTColors.primary,
      foregroundColor: DGTColors.textOnPrimary,
      leading: const BackButton(color: DGTColors.textOnPrimary),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeaderBackground(article: article),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.article});

  final FakeNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DGTColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _DGTBadge(),
          const SizedBox(height: 8),
          Text(
            article.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: DGTColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            article.date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DGTColors.textOnPrimary.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }
}

class _DGTBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DGTColors.textOnPrimary.withAlpha(51),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        DGTStrings.appSubtitle,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: DGTColors.textOnPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({required this.article});

  final FakeNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imagePath.isNotEmpty) ...[
            _ArticleImage(imagePath: article.imagePath),
            const SizedBox(height: 20),
          ],
          _SummaryText(summary: article.summary),
          const SizedBox(height: 16),
          const Divider(color: DGTColors.primary, thickness: 2),
          const SizedBox(height: 16),
          _BodyText(body: article.body),
          const SizedBox(height: 32),
          _DGTFooter(),
        ],
      ),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        semanticLabel: 'Imagen del artículo',
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: DGTColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.article_outlined,
            color: DGTColors.primary,
            size: 48,
            semanticLabel: 'Imagen no disponible',
          ),
        ),
      ),
    );
  }
}

class _SummaryText extends StatelessWidget {
  const _SummaryText({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Text(
      summary,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: DGTColors.textPrimary,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return Text(
      body,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: DGTColors.textPrimary,
        height: 1.7,
      ),
    );
  }
}

class _DGTFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.verified_outlined,
          color: DGTColors.primary,
          size: 16,
          semanticLabel: 'Verificado',
        ),
        const SizedBox(width: 6),
        Text(
          '${DGTStrings.appSubtitle} — Información oficial',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: DGTColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
