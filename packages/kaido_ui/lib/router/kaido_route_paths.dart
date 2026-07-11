/// Route path constants used by `createKaidoRouter`.
class KaidoRoutePaths {
  const KaidoRoutePaths._();

  /// Map screen.
  static const String home = '/';

  /// Point info screen. Expects an `id` path parameter.
  static const String info = '/info/:id';

  /// Image detail screen, nested under [info]. Expects an `id` path
  /// parameter inherited from the parent route.
  static const String image = 'image';

  /// Settings screen.
  static const String settings = '/settings';

  /// Contact form screen.
  static const String contact = '/contact';

  /// Contact location picker screen, nested under [contact].
  static const String contactMap = 'map';

  /// Static HTML content screen. Expects a `page` path parameter.
  static const String html = '/html/:page';

  /// Copyright / license screen.
  static const String copyright = '/copyright';

  /// Splash screen.
  static const String splash = '/splash';
}
