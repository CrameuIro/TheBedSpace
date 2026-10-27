import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../seed.dart';
import '../store.dart';
import '../widgets/ui.dart';

/// The article list lives inside the TV screen (tab 2).
class ArticlesList extends StatelessWidget {
  const ArticlesList({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        SectionHeader(
          title: L.t('articles'),
          subtitle: L.t('read_min').replaceAll('{n}', '2–3'),
        ),
        for (final a in kArticles)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExpressiveCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ArticleDetail(article: a)),
              ),
              child: Row(
                children: [
                  Text(a.icon, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title(L.lang),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          L.tr('read_min', {'n': '${a.readingMinutes}'}),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (state.readArticles.contains(a.id))
                    Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    )
                  else
                    const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ArticleDetail extends StatefulWidget {
  const ArticleDetail({super.key, required this.article});
  final Article article;

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  @override
  void initState() {
    super.initState();
    // Marking as read is deferred so the state change cannot rebuild the route
    // while it is still being pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().markRead(widget.article.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    return Scaffold(
      appBar: AppBar(title: Text(a.title(L.lang))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(a.icon, style: const TextStyle(fontSize: 46)),
          const SizedBox(height: 12),
          Text(
            a.title(L.lang),
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            L.tr('read_min', {'n': '${a.readingMinutes}'}),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            a.body(L.lang),
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(height: 1.55),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                L.t('article_done'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
