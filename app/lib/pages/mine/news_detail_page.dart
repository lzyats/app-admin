import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/news_api.dart';
import 'package:myapp/widgets/app_network_image.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key, required this.article});

  final NewsArticle? article;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final NewsArticle data = article ??
        const NewsArticle(
          articleId: 0,
          categoryId: 0,
          categoryCode: '',
          categoryName: '',
          articleTitle: '',
          summary: '',
          coverImage: '',
          articleContent: '',
          sortOrder: 0,
          topFlag: '0',
          status: '0',
        );
    final String? coverUrl = data.resolvedCoverUrl();
    final String content = data.articleContent.isNotEmpty ? data.articleContent : data.summary;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0828),
      appBar: AppBar(
        title: Text(i18n.t('newsDetailTitle')),
        backgroundColor: const Color(0xFF0A0828),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFF11183E),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: <Widget>[
                    if (coverUrl != null)
                      AppNetworkImage(
                        src: coverUrl,
                        width: double.infinity,
                        height: 320,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: 320,
                          color: const Color(0xFF20284E),
                          child: const Icon(Icons.image_outlined, color: Color(0xFF7D8CA8), size: 60),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 320,
                        color: const Color(0xFF20284E),
                        child: const Icon(Icons.image_outlined, color: Color(0xFF7D8CA8), size: 60),
                      ),
                    Container(
                      width: double.infinity,
                      height: 320,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[Color(0xEE0A0828), Color(0x220A0828)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            data.articleTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.summary,
                            style: const TextStyle(
                              color: Color(0xFFEAF5FF),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                child: _buildContent(content),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String content) {
    if (!_looksLikeHtml(content)) {
      return Text(
        content,
        style: const TextStyle(
          color: Color(0xFFB8C5D9),
          fontSize: 15,
          height: 1.85,
        ),
      );
    }
    return Html(
      data: content,
      extensions: <HtmlExtension>[
        MatcherExtension(
          matcher: (ExtensionContext context) => context.elementName == 'img',
          builder: (ExtensionContext context) {
            final String src = (context.attributes['src'] ?? '').trim();
            final String? resolvedSrc = ApiClient.instance.resolveImageUrl(src);
            if (resolvedSrc == null || resolvedSrc.isEmpty) {
              return const SizedBox.shrink();
            }
            final double? width = double.tryParse((context.attributes['width'] ?? '').trim());
            final double? height = double.tryParse((context.attributes['height'] ?? '').trim());
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AppNetworkImage(
                src: resolvedSrc,
                width: width ?? double.infinity,
                height: height,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            );
          },
        ),
      ],
      style: <String, Style>{
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          color: const Color(0xFFB8C5D9),
          fontSize: FontSize(15),
          lineHeight: const LineHeight(1.85),
        ),
        'p': Style(
          margin: Margins.only(bottom: 12),
          color: const Color(0xFFB8C5D9),
          fontSize: FontSize(15),
          lineHeight: const LineHeight(1.85),
        ),
        'span': Style(
          color: const Color(0xFFB8C5D9),
          fontSize: FontSize(15),
          lineHeight: const LineHeight(1.85),
        ),
        'h1': Style(
          color: Colors.white,
          fontSize: FontSize(26),
          fontWeight: FontWeight.w700,
        ),
        'h2': Style(
          color: Colors.white,
          fontSize: FontSize(22),
          fontWeight: FontWeight.w700,
        ),
        'h3': Style(
          color: Colors.white,
          fontSize: FontSize(19),
          fontWeight: FontWeight.w700,
        ),
        'img': Style(
          margin: Margins.only(top: 8, bottom: 8),
        ),
        'blockquote': Style(
          margin: Margins.only(left: 12, top: 8, bottom: 8),
          padding: HtmlPaddings.only(left: 12),
          border: Border(left: BorderSide(color: const Color(0xFF3B4E7A), width: 3)),
          color: const Color(0xFFD9E4F5),
        ),
      },
    );
  }

  bool _looksLikeHtml(String content) {
    final String trimmed = content.trim();
    return trimmed.startsWith('<') && trimmed.contains('>');
  }
}
