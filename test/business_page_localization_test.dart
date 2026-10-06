import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/business_pages_model.dart';

void main() {
  test('cached pages switch title and content without another request', () {
    final page = BusinessPageModel.fromJson({
      'title': 'Legacy', 'description': 'Legacy text',
      'translations': {
        'ar': {'title': 'من نحن', 'description': '<p>المحتوى العربي</p>'},
        'en': {'title': 'About Us', 'description': '<p>English content</p>'},
      },
    });
    for (final locale in ['ar', 'en', 'ar-EG', 'sa', 'en-US', 'ar']) {
      final arabic = locale == 'ar' || locale == 'ar-EG' || locale == 'sa';
      expect(page.localizedTitle(locale), arabic ? 'من نحن' : 'About Us');
      expect(page.localizedDescription(locale), arabic ? '<p>المحتوى العربي</p>' : '<p>English content</p>');
    }
    final restored = BusinessPageModel.fromJson(page.toJson());
    expect(restored.localizedTitle('ar'), 'من نحن');
    expect(restored.localizedDescription('en'), '<p>English content</p>');
  });

  test('old servers remain compatible', () {
    final page = BusinessPageModel.fromJson({'title': 'About Us', 'description': 'Existing text'});
    expect(page.localizedTitle('en'), 'About Us');
    expect(page.localizedDescription('ar'), 'Existing text');
  });
}
