-- Radar Santa Fe Smart Market: initial private-by-default data model.
-- Apply only to project pwxkisakhqdwbcmvzptr.
begin;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.establishments (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references auth.users(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 160),
  area text,
  address text,
  phone text,
  notes text,
  latitude double precision check (latitude is null or latitude between -90 and 90),
  longitude double precision check (longitude is null or longitude between -180 and 180),
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references auth.users(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 160),
  brand text,
  category text,
  normalized_unit text,
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.price_observations (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references auth.users(id) on delete cascade,
  establishment_id uuid not null references public.establishments(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null check (length(trim(product_name)) between 1 and 160),
  presentation text not null check (length(trim(presentation)) between 1 and 120),
  unit text not null check (length(trim(unit)) between 1 and 40),
  price numeric(14,2) not null check (price > 0),
  currency text not null check (currency in ('CUP','USD','USDT','EUR')),
  observed_at date not null default current_date,
  availability text not null default 'Disponible'
    check (availability in ('Disponible','Agotado','Por encargo')),
  notes text,
  latitude double precision check (latitude is null or latitude between -90 and 90),
  longitude double precision check (longitude is null or longitude between -180 and 180),
  is_public boolean not null default false,
  client_ref text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint price_observations_client_ref_unique unique (created_by, client_ref)
);

create table if not exists public.visits (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references auth.users(id) on delete cascade,
  establishment_id uuid not null references public.establishments(id) on delete cascade,
  visited_at timestamptz not null default now(),
  latitude double precision check (latitude is null or latitude between -90 and 90),
  longitude double precision check (longitude is null or longitude between -180 and 180),
  notes text,
  client_ref text,
  created_at timestamptz not null default now(),
  constraint visits_client_ref_unique unique (created_by, client_ref)
);

create index if not exists establishments_created_by_idx on public.establishments(created_by);
create index if not exists establishments_area_idx on public.establishments(area);
create index if not exists products_created_by_idx on public.products(created_by);
create index if not exists products_name_idx on public.products(lower(name));
create index if not exists price_observations_product_date_idx on public.price_observations(product_name, observed_at desc);
create index if not exists price_observations_establishment_date_idx on public.price_observations(establishment_id, observed_at desc);
create index if not exists price_observations_owner_date_idx on public.price_observations(created_by, observed_at desc);
create index if not exists visits_establishment_date_idx on public.visits(establishment_id, visited_at desc);
create index if not exists visits_owner_date_idx on public.visits(created_by, visited_at desc);

alter table public.profiles enable row level security;
alter table public.establishments enable row level security;
alter table public.products enable row level security;
alter table public.price_observations enable row level security;
alter table public.visits enable row level security;

create policy "profiles_select_self" on public.profiles for select to authenticated
  using ((select auth.uid()) = id);
create policy "profiles_insert_self" on public.profiles for insert to authenticated
  with check ((select auth.uid()) = id);
create policy "profiles_update_self" on public.profiles for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

create policy "establishments_read_owner_or_shared" on public.establishments for select to authenticated
  using ((select auth.uid()) = created_by or is_public = true);
create policy "establishments_insert_owner" on public.establishments for insert to authenticated
  with check ((select auth.uid()) = created_by);
create policy "establishments_update_owner" on public.establishments for update to authenticated
  using ((select auth.uid()) = created_by) with check ((select auth.uid()) = created_by);
create policy "establishments_delete_owner" on public.establishments for delete to authenticated
  using ((select auth.uid()) = created_by);

create policy "products_read_owner_or_shared" on public.products for select to authenticated
  using ((select auth.uid()) = created_by or is_public = true);
create policy "products_insert_owner" on public.products for insert to authenticated
  with check ((select auth.uid()) = created_by);
create policy "products_update_owner" on public.products for update to authenticated
  using ((select auth.uid()) = created_by) with check ((select auth.uid()) = created_by);
create policy "products_delete_owner" on public.products for delete to authenticated
  using ((select auth.uid()) = created_by);

create policy "prices_read_owner_or_shared" on public.price_observations for select to authenticated
  using ((select auth.uid()) = created_by or is_public = true);
create policy "prices_insert_owner" on public.price_observations for insert to authenticated
  with check (
    (select auth.uid()) = created_by
    and exists (
      select 1 from public.establishments e
      where e.id = establishment_id and e.created_by = (select auth.uid())
    )
  );
create policy "prices_update_owner" on public.price_observations for update to authenticated
  using ((select auth.uid()) = created_by)
  with check (
    (select auth.uid()) = created_by
    and exists (
      select 1 from public.establishments e
      where e.id = establishment_id and e.created_by = (select auth.uid())
    )
  );
create policy "prices_delete_owner" on public.price_observations for delete to authenticated
  using ((select auth.uid()) = created_by);

create policy "visits_select_owner" on public.visits for select to authenticated
  using ((select auth.uid()) = created_by);
create policy "visits_insert_owner" on public.visits for insert to authenticated
  with check (
    (select auth.uid()) = created_by
    and exists (
      select 1 from public.establishments e
      where e.id = establishment_id and e.created_by = (select auth.uid())
    )
  );
create policy "visits_update_owner" on public.visits for update to authenticated
  using ((select auth.uid()) = created_by)
  with check (
    (select auth.uid()) = created_by
    and exists (
      select 1 from public.establishments e
      where e.id = establishment_id and e.created_by = (select auth.uid())
    )
  );
create policy "visits_delete_owner" on public.visits for delete to authenticated
  using ((select auth.uid()) = created_by);

-- Explicit grants are required on projects where the Data API does not expose new tables automatically.
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.establishments to authenticated;
grant select, insert, update, delete on public.products to authenticated;
grant select, insert, update, delete on public.price_observations to authenticated;
grant select, insert, update, delete on public.visits to authenticated;

commit;
