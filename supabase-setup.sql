-- =========================================================
-- NOSSO CAIXA — configuração do banco (Supabase, plano grátis)
-- Cole tudo no SQL Editor do Supabase e clique em "Run".
-- Pode rodar mais de uma vez sem problema.
-- =========================================================

-- Famílias (o grupo financeiro de Vini e Kety)
create table if not exists public.familias (
  id uuid primary key default gen_random_uuid(),
  codigo text unique not null,
  criado_em timestamptz not null default now()
);

-- Quem pertence a cada família (uma família por conta)
create table if not exists public.membros (
  user_id uuid primary key references auth.users on delete cascade,
  familia_id uuid not null references public.familias on delete cascade,
  nome text not null,
  criado_em timestamptz not null default now()
);

-- Todos os lançamentos: contas, rendas, dívidas, metas e preferências
create table if not exists public.registros (
  familia_id uuid not null references public.familias on delete cascade,
  id text not null,
  tipo text not null check (tipo in ('contas','rendas','dividas','metas','prefs')),
  dados jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now(),
  atualizado_por uuid default auth.uid(),
  primary key (familia_id, id)
);
create index if not exists registros_tipo_idx on public.registros (familia_id, tipo);

-- Família do usuário logado
create or replace function public.minha_familia()
returns uuid language sql stable security definer set search_path = public as $$
  select familia_id from public.membros where user_id = auth.uid()
$$;

-- Regras de acesso: cada pessoa só enxerga a própria família
alter table public.familias  enable row level security;
alter table public.membros   enable row level security;
alter table public.registros enable row level security;

drop policy if exists "familia: ver a minha" on public.familias;
create policy "familia: ver a minha" on public.familias
  for select to authenticated using (id = public.minha_familia());

drop policy if exists "membros: ver da minha familia" on public.membros;
create policy "membros: ver da minha familia" on public.membros
  for select to authenticated using (familia_id = public.minha_familia());

drop policy if exists "registros: familia le e escreve" on public.registros;
create policy "registros: familia le e escreve" on public.registros
  for all to authenticated
  using (familia_id = public.minha_familia())
  with check (familia_id = public.minha_familia());

-- Criar família (primeiro acesso) — devolve o código de convite
create or replace function public.criar_familia(p_nome text)
returns json language plpgsql security definer set search_path = public as $$
declare f uuid; c text;
begin
  if auth.uid() is null then raise exception 'nao_logado'; end if;
  if exists (select 1 from membros where user_id = auth.uid()) then raise exception 'ja_tem_familia'; end if;
  loop
    c := upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));
    exit when not exists (select 1 from familias where codigo = c);
  end loop;
  insert into familias (codigo) values (c) returning id into f;
  insert into membros (user_id, familia_id, nome) values (auth.uid(), f, coalesce(nullif(trim(p_nome), ''), 'Eu'));
  return json_build_object('id', f, 'codigo', c);
end $$;

-- Entrar na família com o código (segundo acesso)
create or replace function public.entrar_familia(p_codigo text, p_nome text)
returns uuid language plpgsql security definer set search_path = public as $$
declare f uuid;
begin
  if auth.uid() is null then raise exception 'nao_logado'; end if;
  if exists (select 1 from membros where user_id = auth.uid()) then raise exception 'ja_tem_familia'; end if;
  select id into f from familias where codigo = upper(trim(p_codigo));
  if f is null then raise exception 'codigo_invalido'; end if;
  if (select count(*) from membros where familia_id = f) >= 2 then raise exception 'familia_completa'; end if;
  insert into membros (user_id, familia_id, nome) values (auth.uid(), f, coalesce(nullif(trim(p_nome), ''), 'Eu'));
  return f;
end $$;

revoke all on function public.criar_familia(text) from public, anon;
revoke all on function public.entrar_familia(text, text) from public, anon;
grant execute on function public.criar_familia(text) to authenticated;
grant execute on function public.entrar_familia(text, text) to authenticated;
grant execute on function public.minha_familia() to authenticated;

-- Sincronização em tempo real entre os dois celulares
do $$ begin
  alter publication supabase_realtime add table public.registros;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.membros;
exception when duplicate_object then null; end $$;

-- Comprovantes (fotos e PDFs), privados por família
insert into storage.buckets (id, name, public) values ('comprovantes', 'comprovantes', false)
on conflict (id) do nothing;

drop policy if exists "comprovantes: familia" on storage.objects;
create policy "comprovantes: familia" on storage.objects
  for all to authenticated
  using (bucket_id = 'comprovantes' and (storage.foldername(name))[1] = public.minha_familia()::text)
  with check (bucket_id = 'comprovantes' and (storage.foldername(name))[1] = public.minha_familia()::text);
