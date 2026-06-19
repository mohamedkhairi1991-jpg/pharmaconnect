Map<String, Object?> publishedProductJson({
  bool includeArabic = false,
  bool includeMedia = false,
  bool includeBrochure = false,
}) {
  const String timestamp = '2026-06-19T12:00:00Z';
  return <String, Object?>{
    'id': 'product-id',
    'category': 'dietary_supplement',
    'status': 'published',
    'presentation_fingerprint': 'fingerprint',
    'submitted_by': 'company-profile',
    'submitted_at': timestamp,
    'reviewed_by': 'admin-profile',
    'reviewed_at': timestamp,
    'review_reason': null,
    'published_by': 'admin-profile',
    'published_at': timestamp,
    'hidden_by': null,
    'hidden_at': null,
    'hidden_reason': null,
    'archived_by': null,
    'archived_at': null,
    'archive_reason': null,
    'created_at': timestamp,
    'updated_at': timestamp,
    'companies': <String, Object?>{
      'id': 'company-id',
      'company_name': 'Company',
      'legal_name': 'Company LLC',
      'country_id': 'iraq-id',
      'city_id': null,
      'status': 'verified',
    },
    'drug_classes': drugClassJson(),
    'generic_drugs': null,
    'product_translations': <Object?>[
      productTranslationJson('en', 'English Brand'),
      if (includeArabic) productTranslationJson('ar', 'Arabic Brand'),
    ],
    'product_markets': <Object?>[
      <String, Object?>{
        'id': 'market-id',
        'country_id': 'iraq-id',
        'strength': '100 mg',
        'dosage_form': 'tablet',
        'route': 'oral',
        'pack_size': '30 tablets',
        'market_status': 'marketed_in_iraq',
        'registration_status': 'not_recorded',
        'registration_number': null,
        'registration_authority': null,
        'registration_expires_on': null,
        'created_at': timestamp,
        'updated_at': timestamp,
        'product_market_translations': <Object?>[
          marketTranslationJson('en'),
          if (includeArabic) marketTranslationJson('ar'),
        ],
        'product_brochures': <Object?>[
          if (includeBrochure)
            <String, Object?>{
              'id': 'brochure-id',
              'product_market_id': 'market-id',
              'locale': 'en',
              'title': 'Brochure',
              'storage_path': 'metadata/brochure.pdf',
              'mime_type': 'application/pdf',
              'file_size_bytes': 100,
              'version': 1,
              'is_current': true,
              'uploaded_by': 'company-profile',
              'created_at': timestamp,
              'updated_at': timestamp,
            },
        ],
      },
    ],
    'product_specialties': <Object?>[
      <String, Object?>{
        'specialties': <String, Object?>{
          'id': 'specialty-id',
          'code': 'cardiology',
          'profession_type': 'physician',
          'is_active': true,
          'specialty_translations': <Object?>[
            <String, Object?>{
              'locale': 'en',
              'name': 'Cardiology',
              'description': null,
            },
          ],
        },
      },
    ],
    'product_media': <Object?>[
      if (includeMedia)
        <String, Object?>{
          'id': 'media-id',
          'media_type': 'product_image',
          'storage_path': 'metadata/product.png',
          'mime_type': 'image/png',
          'file_size_bytes': 100,
          'sort_order': 0,
          'is_primary': true,
          'uploaded_by': 'company-profile',
          'created_at': timestamp,
          'updated_at': timestamp,
        },
    ],
  };
}

Map<String, Object?> draftProductJson() {
  final Map<String, Object?> result = publishedProductJson();
  result
    ..['status'] = 'draft'
    ..['presentation_fingerprint'] = null
    ..['submitted_by'] = null
    ..['submitted_at'] = null
    ..['reviewed_by'] = null
    ..['reviewed_at'] = null
    ..['published_by'] = null
    ..['published_at'] = null
    ..['product_markets'] = <Object?>[]
    ..['product_specialties'] = <Object?>[];
  return result;
}

Map<String, Object?> drugClassJson() => <String, Object?>{
  'id': 'class-id',
  'code': 'class_code',
  'parent_drug_class_id': null,
  'is_active': true,
  'drug_class_translations': <Object?>[
    <String, Object?>{
      'locale': 'en',
      'name': 'Drug Class',
      'description': null,
    },
  ],
};

Map<String, Object?> productTranslationJson(String locale, String name) =>
    <String, Object?>{
      'id': 'translation-$locale',
      'locale': locale,
      'brand_name': name,
      'created_at': '2026-06-19T12:00:00+03:00',
      'updated_at': '2026-06-19T12:00:00+03:00',
    };

Map<String, Object?> marketTranslationJson(String locale) => <String, Object?>{
  'id': 'market-translation-$locale',
  'locale': locale,
  'storage_conditions': 'Store dry',
  'approved_indications': 'Approved indication',
  'usual_adult_dose': 'One daily',
  'contraindications': 'Hypersensitivity',
  'common_adverse_effects': 'Mild effects',
  'created_at': '2026-06-19T12:00:00Z',
  'updated_at': '2026-06-19T12:00:00Z',
};
