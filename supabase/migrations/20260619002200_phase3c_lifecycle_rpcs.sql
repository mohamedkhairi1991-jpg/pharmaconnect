create or replace function public.submit_product_for_review(
  p_product_id uuid
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  current_row public.products;
  updated_row public.products;
  validation_errors text[];
begin
  select * into current_row
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception using errcode = 'P0002',
      message = 'The product does not exist.';
  end if;

  if current_row.status not in ('draft', 'changes_requested')
    or not private.can_manage_official_product_content(p_product_id) then
    raise exception using errcode = '42501',
      message = 'This product cannot be submitted by the current user.';
  end if;

  actor_id := private.current_profile_id();
  perform private.refresh_product_presentation_fingerprint(p_product_id);
  perform private.refresh_product_search_keywords(p_product_id);
  validation_errors :=
    private.product_validation_errors(p_product_id, 'submission');

  if cardinality(validation_errors) > 0 then
    raise exception using errcode = '23514',
      message = 'Product submission requirements are incomplete.',
      detail = array_to_string(validation_errors, ',');
  end if;

  update public.products
  set
    status = 'submitted',
    submitted_by = actor_id,
    submitted_at = timezone('utc', now()),
    reviewed_by = null,
    reviewed_at = null,
    review_reason = null,
    published_by = null,
    published_at = null,
    hidden_by = null,
    hidden_at = null,
    hidden_reason = null,
    archived_by = null,
    archived_at = null,
    archive_reason = null,
    updated_by = actor_id
  where id = p_product_id
  returning * into updated_row;

  perform private.write_audit_log(
    actor_id, 'product_submitted', 'product', p_product_id,
    jsonb_build_object('status', current_row.status),
    jsonb_build_object(
      'status', updated_row.status,
      'company_id', updated_row.company_id
    )
  );

  return updated_row;
end;
$$;

create or replace function public.withdraw_product_submission(
  p_product_id uuid
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  current_row public.products;
  updated_row public.products;
begin
  select * into current_row
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception using errcode = 'P0002',
      message = 'The product does not exist.';
  end if;

  if current_row.status not in ('submitted', 'changes_requested')
    or not private.has_company_role(
      current_row.company_id,
      array['company_admin', 'product_manager']::public.company_role[]
    ) then
    raise exception using errcode = '42501',
      message = 'This product submission cannot be withdrawn.';
  end if;

  actor_id := private.current_profile_id();

  update public.products
  set
    status = 'draft',
    submitted_by = null,
    submitted_at = null,
    reviewed_by = null,
    reviewed_at = null,
    review_reason = null,
    published_by = null,
    published_at = null,
    hidden_by = null,
    hidden_at = null,
    hidden_reason = null,
    archived_by = null,
    archived_at = null,
    archive_reason = null,
    updated_by = actor_id
  where id = p_product_id
  returning * into updated_row;

  perform private.write_audit_log(
    actor_id, 'product_submission_withdrawn', 'product', p_product_id,
    jsonb_build_object('status', current_row.status),
    jsonb_build_object(
      'status', updated_row.status,
      'company_id', updated_row.company_id
    )
  );

  return updated_row;
end;
$$;

create or replace function public.archive_own_product(
  p_product_id uuid,
  p_reason text
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  current_row public.products;
  updated_row public.products;
begin
  if p_reason is null or btrim(p_reason) = '' then
    raise exception using errcode = '22023',
      message = 'An archive reason is required.';
  end if;

  select * into current_row
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception using errcode = 'P0002',
      message = 'The product does not exist.';
  end if;

  if current_row.status not in ('draft', 'changes_requested')
    or not private.has_company_role(
      current_row.company_id,
      array['company_admin', 'product_manager']::public.company_role[]
    ) then
    raise exception using errcode = '42501',
      message = 'This product cannot be archived by the current user.';
  end if;

  actor_id := private.current_profile_id();

  update public.products
  set
    status = 'archived',
    archived_by = actor_id,
    archived_at = timezone('utc', now()),
    archive_reason = btrim(p_reason),
    updated_by = actor_id
  where id = p_product_id
  returning * into updated_row;

  perform private.write_audit_log(
    actor_id, 'product_archived', 'product', p_product_id,
    jsonb_build_object('status', current_row.status),
    jsonb_build_object(
      'status', updated_row.status,
      'company_id', updated_row.company_id,
      'reason', updated_row.archive_reason
    )
  );

  return updated_row;
end;
$$;

create or replace function public.admin_request_product_changes(
  p_product_id uuid,
  p_reason text
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  current_row public.products;
  updated_row public.products;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  if p_reason is null or btrim(p_reason) = '' then
    raise exception using errcode = '22023',
      message = 'A review reason is required.';
  end if;

  select * into current_row
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception using errcode = 'P0002',
      message = 'The product does not exist.';
  end if;

  if current_row.status <> 'submitted' then
    raise exception using errcode = '23514',
      message = 'Only submitted products may be returned for changes.';
  end if;

  actor_id := private.current_profile_id();

  update public.products
  set
    status = 'changes_requested',
    reviewed_by = actor_id,
    reviewed_at = timezone('utc', now()),
    review_reason = btrim(p_reason),
    updated_by = actor_id
  where id = p_product_id
  returning * into updated_row;

  perform private.write_audit_log(
    actor_id, 'product_changes_requested', 'product', p_product_id,
    jsonb_build_object('status', current_row.status),
    jsonb_build_object(
      'status', updated_row.status,
      'company_id', updated_row.company_id,
      'reason', updated_row.review_reason
    )
  );

  return updated_row;
end;
$$;

create or replace function public.admin_publish_product(
  p_product_id uuid
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  current_row public.products;
  updated_row public.products;
  validation_errors text[];
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  select * into current_row
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception using errcode = 'P0002',
      message = 'The product does not exist.';
  end if;

  if current_row.status <> 'submitted' then
    raise exception using errcode = '23514',
      message = 'Only submitted products may be published.';
  end if;

  actor_id := private.current_profile_id();
  perform private.refresh_product_presentation_fingerprint(p_product_id);
  perform private.refresh_product_search_keywords(p_product_id);
  validation_errors :=
    private.product_validation_errors(p_product_id, 'publication');

  if cardinality(validation_errors) > 0 then
    raise exception using errcode = '23514',
      message = 'Product publication requirements are incomplete.',
      detail = array_to_string(validation_errors, ',');
  end if;

  update public.products
  set
    status = 'published',
    reviewed_by = actor_id,
    reviewed_at = timezone('utc', now()),
    review_reason = null,
    published_by = actor_id,
    published_at = timezone('utc', now()),
    hidden_by = null,
    hidden_at = null,
    hidden_reason = null,
    archived_by = null,
    archived_at = null,
    archive_reason = null,
    updated_by = actor_id
  where id = p_product_id
  returning * into updated_row;

  perform private.write_audit_log(
    actor_id, 'product_published', 'product', p_product_id,
    jsonb_build_object('status', current_row.status),
    jsonb_build_object(
      'status', updated_row.status,
      'company_id', updated_row.company_id
    )
  );

  return updated_row;
end;
$$;

create or replace function public.admin_hide_product(
  p_product_id uuid,
  p_reason text
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  current_row public.products;
  updated_row public.products;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  if p_reason is null or btrim(p_reason) = '' then
    raise exception using errcode = '22023',
      message = 'A hiding reason is required.';
  end if;

  select * into current_row
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception using errcode = 'P0002',
      message = 'The product does not exist.';
  end if;

  if current_row.status not in ('draft', 'published') then
    raise exception using errcode = '23514',
      message = 'Only draft or published products may be hidden.';
  end if;

  actor_id := private.current_profile_id();

  update public.products
  set
    status = 'hidden',
    hidden_by = actor_id,
    hidden_at = timezone('utc', now()),
    hidden_reason = btrim(p_reason),
    updated_by = actor_id
  where id = p_product_id
  returning * into updated_row;

  perform private.write_audit_log(
    actor_id, 'product_hidden', 'product', p_product_id,
    jsonb_build_object('status', current_row.status),
    jsonb_build_object(
      'status', updated_row.status,
      'company_id', updated_row.company_id,
      'reason', updated_row.hidden_reason
    )
  );

  return updated_row;
end;
$$;

create or replace function public.admin_restore_product(
  p_product_id uuid,
  p_destination_status public.product_status,
  p_reason text
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  current_row public.products;
  updated_row public.products;
  validation_errors text[];
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  if p_destination_status not in ('published', 'changes_requested') then
    raise exception using errcode = '22023',
      message = 'Restore destination must be published or changes_requested.';
  end if;

  if p_destination_status = 'changes_requested'
    and (p_reason is null or btrim(p_reason) = '') then
    raise exception using errcode = '22023',
      message = 'A review reason is required when restoring for changes.';
  end if;

  select * into current_row
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception using errcode = 'P0002',
      message = 'The product does not exist.';
  end if;

  if current_row.status <> 'hidden' then
    raise exception using errcode = '23514',
      message = 'Only hidden products may be restored.';
  end if;

  actor_id := private.current_profile_id();

  if p_destination_status = 'published' then
    perform private.refresh_product_presentation_fingerprint(p_product_id);
    perform private.refresh_product_search_keywords(p_product_id);
    validation_errors :=
      private.product_validation_errors(p_product_id, 'publication');
    if cardinality(validation_errors) > 0
      or current_row.submitted_by is null
      or current_row.submitted_at is null then
      raise exception using errcode = '23514',
        message = 'The hidden product no longer satisfies publication requirements.',
        detail = array_to_string(validation_errors, ',');
    end if;

    update public.products
    set
      status = 'published',
      reviewed_by = actor_id,
      reviewed_at = timezone('utc', now()),
      review_reason = null,
      published_by = actor_id,
      published_at = timezone('utc', now()),
      hidden_by = null,
      hidden_at = null,
      hidden_reason = null,
      updated_by = actor_id
    where id = p_product_id
    returning * into updated_row;
  else
    if current_row.submitted_by is null
      or current_row.submitted_at is null then
      raise exception using errcode = '23514',
        message = 'This hidden product has no prior submission to return.';
    end if;

    update public.products
    set
      status = 'changes_requested',
      reviewed_by = actor_id,
      reviewed_at = timezone('utc', now()),
      review_reason = btrim(p_reason),
      published_by = null,
      published_at = null,
      hidden_by = null,
      hidden_at = null,
      hidden_reason = null,
      updated_by = actor_id
    where id = p_product_id
    returning * into updated_row;
  end if;

  perform private.write_audit_log(
    actor_id, 'product_restored', 'product', p_product_id,
    jsonb_build_object('status', current_row.status),
    jsonb_build_object(
      'status', updated_row.status,
      'company_id', updated_row.company_id,
      'reason', case when p_reason is null then null else btrim(p_reason) end
    )
  );

  return updated_row;
end;
$$;

create or replace function public.admin_archive_product(
  p_product_id uuid,
  p_reason text
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  current_row public.products;
  updated_row public.products;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  if p_reason is null or btrim(p_reason) = '' then
    raise exception using errcode = '22023',
      message = 'An archive reason is required.';
  end if;

  select * into current_row
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception using errcode = 'P0002',
      message = 'The product does not exist.';
  end if;

  if current_row.status = 'archived' then
    raise exception using errcode = '23514',
      message = 'Archived products are terminal.';
  end if;

  actor_id := private.current_profile_id();

  update public.products
  set
    status = 'archived',
    archived_by = actor_id,
    archived_at = timezone('utc', now()),
    archive_reason = btrim(p_reason),
    updated_by = actor_id
  where id = p_product_id
  returning * into updated_row;

  perform private.write_audit_log(
    actor_id, 'product_archived', 'product', p_product_id,
    jsonb_build_object('status', current_row.status),
    jsonb_build_object(
      'status', updated_row.status,
      'company_id', updated_row.company_id,
      'reason', updated_row.archive_reason
    )
  );

  return updated_row;
end;
$$;

revoke all on function public.submit_product_for_review(uuid) from public;
revoke all on function public.withdraw_product_submission(uuid) from public;
revoke all on function public.archive_own_product(uuid, text) from public;
revoke all on function public.admin_request_product_changes(uuid, text)
  from public;
revoke all on function public.admin_publish_product(uuid) from public;
revoke all on function public.admin_hide_product(uuid, text) from public;
revoke all on function public.admin_restore_product(
  uuid, public.product_status, text
) from public;
revoke all on function public.admin_archive_product(uuid, text) from public;
