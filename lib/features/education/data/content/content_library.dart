import '../../domain/article.dart';
import 'articles_care.dart';
import 'articles_desire_ejaculation.dart';
import 'articles_foundations.dart';
import 'articles_lifestyle.dart';
import 'articles_relationships.dart';

/// Bundled, offline content. To add content, append to one of the lists;
/// the UI is driven entirely by these models.
const bundledArticles = <Article>[
  ...foundationArticles,
  ...desireEjaculationArticles,
  ...relationshipArticles,
  ...lifestyleArticles,
  ...careArticles,
];
