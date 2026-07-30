abstract final class CatalogTables {
  static const String healthcareProfessionals = 'healthcare_professionals';
  static const String companyUsers = 'company_users';
  static const String products = 'products';
  static const String drugClasses = 'drug_classes';
  static const String activeIngredients = 'active_ingredients';
  static const String genericDrugs = 'generic_drugs';
  static const String specialties = 'specialties';
}

abstract final class CatalogReferenceIds {
  static const String iraqCountryId = '00000000-0000-4000-8000-000000000368';
}

abstract final class CatalogQueryProjections {
  static const String professionalEligibility =
      'id,profile_id,profession_type,specialty_id,verification_status,'
      'profiles!healthcare_professionals_profile_id_fkey!inner(status)';

  static const String companyAccess =
      'id,company_id,company_role,is_active,'
      'companies!inner(company_name,status),'
      'profiles!company_users_profile_id_fkey!inner(status)';

  static const String drugClass =
      'id,code,parent_drug_class_id,is_active,'
      'drug_class_translations(locale,name,description)';

  static const String activeIngredient =
      'id,code,is_active,'
      'active_ingredient_translations(locale,name,description)';

  static const String genericDrug =
      'id,code,is_active,'
      'drug_classes($drugClass),'
      'generic_drug_translations(locale,name,description),'
      'generic_drug_ingredients(sort_order,'
      'active_ingredients($activeIngredient))';

  static const String specialty =
      'id,code,profession_type,is_active,'
      'specialty_translations(locale,name,description)';

  static const String product =
      'id,category,status,presentation_fingerprint,'
      'submitted_by,submitted_at,reviewed_by,reviewed_at,review_reason,'
      'published_by,published_at,hidden_by,hidden_at,hidden_reason,'
      'archived_by,archived_at,archive_reason,created_at,updated_at,'
      'companies(id,company_name,legal_name,country_id,city_id,status),'
      'drug_classes($drugClass),'
      'generic_drugs($genericDrug),'
      'product_translations(id,locale,brand_name,created_at,updated_at),'
      'product_markets(id,country_id,strength,dosage_form,route,pack_size,'
      'market_status,registration_status,registration_number,'
      'registration_authority,registration_expires_on,created_at,updated_at,'
      'product_market_translations(id,locale,storage_conditions,'
      'approved_indications,usual_adult_dose,contraindications,'
      'common_adverse_effects,created_at,updated_at),'
      'product_brochures(id,product_market_id,locale,title,storage_path,'
      'mime_type,file_size_bytes,version,is_current,uploaded_by,'
      'created_at,updated_at)),'
      'product_specialties(specialties($specialty)),'
      'product_media(id,media_type,storage_path,mime_type,file_size_bytes,'
      'sort_order,is_primary,uploaded_by,created_at,updated_at)';
}

abstract final class CatalogRpcNames {
  static const String createProductDraft = 'create_product_draft';
  static const String updateProductDraft = 'update_product_draft';
  static const String upsertProductTranslation = 'upsert_product_translation';
  static const String upsertProductMarket = 'upsert_product_market';
  static const String upsertProductMarketTranslation =
      'upsert_product_market_translation';
  static const String setProductSpecialties = 'set_product_specialties';
  static const String upsertProductMediaMetadata =
      'upsert_product_media_metadata';
  static const String upsertProductBrochureMetadata =
      'upsert_product_brochure_metadata';
  static const String upsertProductKeywordAlias =
      'upsert_product_keyword_alias';
  static const String submitProductForReview = 'submit_product_for_review';
  static const String withdrawProductSubmission = 'withdraw_product_submission';
  static const String archiveOwnProduct = 'archive_own_product';
  static const String adminRequestProductChanges =
      'admin_request_product_changes';
  static const String adminPublishProduct = 'admin_publish_product';
  static const String adminHideProduct = 'admin_hide_product';
  static const String adminRestoreProduct = 'admin_restore_product';
  static const String adminArchiveProduct = 'admin_archive_product';
  static const String adminCreateDrugClass = 'admin_create_drug_class';
  static const String adminUpdateDrugClass = 'admin_update_drug_class';
  static const String adminSetDrugClassActive = 'admin_set_drug_class_active';
  static const String adminUpsertDrugClassTranslation =
      'admin_upsert_drug_class_translation';
  static const String adminCreateActiveIngredient =
      'admin_create_active_ingredient';
  static const String adminUpdateActiveIngredient =
      'admin_update_active_ingredient';
  static const String adminSetActiveIngredientActive =
      'admin_set_active_ingredient_active';
  static const String adminUpsertActiveIngredientTranslation =
      'admin_upsert_active_ingredient_translation';
  static const String adminCreateGenericDrug = 'admin_create_generic_drug';
  static const String adminUpdateGenericDrug = 'admin_update_generic_drug';
  static const String adminUpsertGenericDrugTranslation =
      'admin_upsert_generic_drug_translation';
  static const String adminSetGenericDrugIngredients =
      'admin_set_generic_drug_ingredients';
  static const String adminSetGenericDrugActive =
      'admin_set_generic_drug_active';
  static const String adminCreateSpecialty = 'admin_create_specialty';
  static const String adminUpdateSpecialty = 'admin_update_specialty';
  static const String adminSetSpecialtyActive = 'admin_set_specialty_active';
  static const String adminUpsertSpecialtyTranslation =
      'admin_upsert_specialty_translation';
}
