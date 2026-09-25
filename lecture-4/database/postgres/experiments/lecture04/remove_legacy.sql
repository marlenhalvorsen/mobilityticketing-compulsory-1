-- Start only after your ID-only reader and writer are ready.
begin;
set local lock_timeout = '3s';

-- Inspect views that may depend on tickets.product_code.
select schemaname, viewname, definition
from pg_views
where definition ilike '%product_code%';

-- Inspect normal functions that may depend on product_code.
select n.nspname as schema_name,
       p.proname as function_name,
       pg_get_functiondef(p.oid) as definition
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where p.prokind = 'f'
  and pg_get_functiondef(p.oid) ilike '%product_code%';

-- CONTRACT:
-- Remove the legacy column without CASCADE.
alter table tickets
  drop column product_code;

-- Test the final ID-only reader.
-- Notice that product code comes from products (p.code),
-- not from tickets.
select t.id,
       t.product_id,
       p.code as product_code,
       t.price,
       t.currency
from tickets t
join products p
  on p.id = t.product_id
order by t.id;

-- Test the final ID-only writer.
-- tickets.product_code no longer exists here.
insert into tickets
    (id, user_id, trip_id, ticket_code, status,
     product_id,
     valid_from_utc, valid_to_utc, price, currency)
select
    'LAB04-FINAL-1',
    t.user_id,
    t.trip_id,
    'LAB04-CODE-FINAL-1',
    t.status,
    p.id,
    t.valid_from_utc,
    t.valid_to_utc,
    36.00,
    t.currency
from tickets t
join products p
  on p.id = 'cecb3cb2-e265-4471-af77-fae7e0b06ce5'
where t.id = 'TICKET-1';

-- Verify that the final writer actually created the ticket.
select t.id,
       t.product_id,
       p.code as product_code,
       t.price,
       t.currency
from tickets t
join products p
  on p.id = t.product_id
where t.id = 'LAB04-FINAL-1';

-- This is only a rehearsal.
-- Restore product_code and remove LAB04-FINAL-1 by rolling back
-- the entire transaction.
rollback;