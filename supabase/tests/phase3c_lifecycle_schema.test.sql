begin;

select plan(24);

select is(
  (
    select array_agg(enumlabel::text order by enumsortorder)
    from pg_enum
    join pg_type on pg_type.oid = pg_enum.enumtypid
    where pg_type.typname = 'product_status'
  ),
  array[
    'draft',
    'submitted',
    'changes_requested',
    'published',
    'hidden',
    'archived'
  ]::text[],
  'official product lifecycle enum contains the approved states'
);

select has_column('public', 'products', 'submitted_by', 'submitted_by exists');
select has_column('public', 'products', 'submitted_at', 'submitted_at exists');
select has_column('public', 'products', 'reviewed_by', 'reviewed_by exists');
select has_column('public', 'products', 'reviewed_at', 'reviewed_at exists');
select has_column('public', 'products', 'review_reason', 'review_reason exists');
select has_column('public', 'products', 'published_by', 'published_by exists');
select has_column('public', 'products', 'published_at', 'published_at exists');
select has_column('public', 'products', 'hidden_by', 'hidden_by exists');
select has_column('public', 'products', 'hidden_at', 'hidden_at exists');
select has_column('public', 'products', 'hidden_reason', 'hidden_reason exists');
select has_column('public', 'products', 'archived_by', 'archived_by exists');
select has_column('public', 'products', 'archived_at', 'archived_at exists');
select has_column('public', 'products', 'archive_reason', 'archive_reason exists');

select has_function(
  'public', 'submit_product_for_review', array['uuid']
);
select has_function(
  'public', 'withdraw_product_submission', array['uuid']
);
select has_function(
  'public', 'archive_own_product', array['uuid', 'text']
);
select has_function(
  'public', 'admin_request_product_changes', array['uuid', 'text']
);
select has_function(
  'public', 'admin_publish_product', array['uuid']
);
select has_function(
  'public', 'admin_hide_product', array['uuid', 'text']
);
select has_function(
  'public',
  'admin_restore_product',
  array['uuid', 'product_status', 'text']
);
select has_function(
  'public', 'admin_archive_product', array['uuid', 'text']
);
select has_function(
  'private', 'is_official_catalog_product_visible', array['uuid']
);
select has_function(
  'private', 'can_read_official_catalog_product', array['uuid']
);

select * from finish();
rollback;
