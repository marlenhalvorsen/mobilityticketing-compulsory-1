-- Copy this file to 011_ticketing_integrity.sql and complete it from your integrity map.
-- Keep the starter DDL unchanged.

begin;

alter table trips
    alter column capacity set not null,
    alter column reserved_seats set not null,
    add constraint trips_capacity_non_negative
        check (capacity >= 0),
    add constraint trips_reserved_seats_valid
        check (reserved_seats between 0 and capacity);

alter table tickets
    alter column currency set not null,
    add constraint tickets_user_fk
        foreign key (user_id) references users(id),
    add constraint tickets_trip_fk
        foreign key (trip_id) references trips(id),
    add constraint tickets_price_non_negative
        check (price >= 0),
    add constraint tickets_ticket_code_unique
        unique (ticket_code),
    add constraint tickets_validity_window
        check (valid_from_utc <= valid_to_utc),
    add constraint tickets_product_code_fk
        foreign key (product_code) references products(code),
    add constraint tickets_id_ticket_code_unique
        unique (id, ticket_code),
    add constraint tickets_status_valid
        check (status in (
            'Pending',
            'Active',
            'Validated',
            'Cancelled',
            'Expired'
        ));

alter table products
    alter column currency set not null,
    add constraint products_price_non_negative
        check (price >= 0);

alter table payments
    alter column currency set not null,
    add constraint payments_tickets_fk
        foreign key (ticket_id) references tickets(id),
    add constraint payments_user_id_fk
        foreign key (user_id) references users(id),
    add constraint payment_amount_non_negative
        check (amount >= 0),
    add constraint payment_external_payment_reference_unique
        unique (external_payment_reference);

alter table validations
    add constraint validations_ticket_id_ticket_code_fk
        foreign key (ticket_id, ticket_code) references tickets(id, ticket_code);
    
-- TODO: product reference, ticket-code identity, status, price,
-- currency, validity window and remaining foreign keys.
-- Decide how duplicated validations.ticket_code should be protected.
-- Name every constraint so tests and later migrations can identify it.

commit;
