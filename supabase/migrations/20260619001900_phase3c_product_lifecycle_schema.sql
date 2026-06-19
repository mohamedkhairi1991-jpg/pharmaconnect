alter type public.product_status add value if not exists 'submitted';
alter type public.product_status add value if not exists 'changes_requested';
alter type public.product_status add value if not exists 'published';
alter type public.product_status add value if not exists 'hidden';
alter type public.product_status add value if not exists 'archived';

alter table public.products
  drop constraint products_draft_only;

alter table public.products
  add column submitted_by uuid references public.profiles(id)
    on update restrict on delete restrict,
  add column submitted_at timestamptz,
  add column reviewed_by uuid references public.profiles(id)
    on update restrict on delete restrict,
  add column reviewed_at timestamptz,
  add column review_reason text,
  add column published_by uuid references public.profiles(id)
    on update restrict on delete restrict,
  add column published_at timestamptz,
  add column hidden_by uuid references public.profiles(id)
    on update restrict on delete restrict,
  add column hidden_at timestamptz,
  add column hidden_reason text,
  add column archived_by uuid references public.profiles(id)
    on update restrict on delete restrict,
  add column archived_at timestamptz,
  add column archive_reason text,
  add constraint products_review_reason_not_blank check (
    review_reason is null or btrim(review_reason) <> ''
  ),
  add constraint products_hidden_reason_not_blank check (
    hidden_reason is null or btrim(hidden_reason) <> ''
  ),
  add constraint products_archive_reason_not_blank check (
    archive_reason is null or btrim(archive_reason) <> ''
  );

create index products_status_submitted_idx
  on public.products (status, submitted_at desc);

create index products_status_reviewed_idx
  on public.products (status, reviewed_at desc);

create index products_status_published_idx
  on public.products (status, published_at desc);

create index products_category_status_idx
  on public.products (category, status);

create index products_updated_at_idx
  on public.products (updated_at desc);
