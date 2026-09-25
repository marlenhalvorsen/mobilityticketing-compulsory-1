# Compulsory Assignment 1 review guide

Group members: Marlen Halvorsen

Submitted commit: See Moodle submission

Setup og reset findes i README-filerne under de enkelte lectures.

## Where to find the work

### Lecture 1 – Introduction to Databases

Model, workload map og resultater findes i [lab.md](lecture-1/docs/lab.md). ER-diagrammet findes i [er-diagram.puml](lecture-1/docs/er-diagram.puml). Schema og seed data findes i [001_relational_baseline.sql](lecture-1/database/postgres/001_relational_baseline.sql) og [002_seed.sql](lecture-1/database/postgres/002_seed.sql). De tre route/timetable queries findes i [003_queries.sql.example]([003_queries.sql](lecture-1/database/postgres/003_queries.sql)).

Jeg valgte `(route_id, stop_sequence)` som primary key for `route_stops`. Det gør at samme stop kan forekomme flere gange på samme route på forskellige positioner.

### Lecture 2 – SQL Operations

Integrity map og test evidence findes i [integrity-map-template.md](lecture-2/docs/integrity-map-template.md). Constraints findes i [011_ticketing_integrity.sql](lecture-2/database/postgres/migrations/011_ticketing_integrity.sql), og rejected-write tests findes i [constraints_should_fail.sql](lecture-2/database/postgres/experiments/constraints_should_fail.sql).

To regler jeg kan vise er at capacity ikke må være negativ, og at en ticket skal referere til en eksisterende trip. De bliver håndhævet med henholdsvis en CHECK constraint og en FOREIGN KEY. En begrænsning er at constraints alene ikke løser concurrent seat reservations.

### Lecture 3 – SQL Programmability

Base query findes i [base_revenue.sql](lecture-3/database/postgres/queries/base_revenue.sql). Reporting function, trigger og materialized view findes i [020_reporting_function.sql](lecture-3/database/postgres/migrations/020_reporting_function.sql), [021_daily_revenue_trigger.sql](lecture-3/database/postgres/migrations/021_daily_revenue_trigger.sql) og [022_daily_captured_revenue.sql](lecture-3/database/postgres/migrations/022_daily_captured_revenue.sql). Eksperimentet findes i [reporting_cases.sql](lecture-3/database/postgres/experiments/reporting_cases.sql), og resultaterne findes i [lab-results.md](lecture-3/docs/lab-results.md).

Et eksempel på stale data er efter en payment ændres fra Failed til Captured. Direct query og function viste 122 DKK, mens materialized view stadig viste 36 DKK. Materialized view bliver korrekt igen efter refresh. Trigger-summary blev heller ikke opdateret, fordi triggeren kun håndterede inserts.

### Lecture 4 – Schema Migration

Migrationen fra `product_code` til `product_id` findes i [030_expand_product_identity.sql](lecture-4/database/postgres/migrations/030_expand_product_identity.sql), [031_backfill_ticket_product.sql](lecture-4/database/postgres/migrations/031_backfill_ticket_product.sql) og [032_require_ticket_product.sql](lecture-4/database/postgres/migrations/032_require_ticket_product.sql). Old/new readers og writers, compatibility checks, verification og removal test findes i [lecture04 experiments](lecture-4/database/postgres/experiments/lecture04/). Resultatet er beskrevet i [lecture04.md](lecture-4/docs/lecture04.md).

Migrationen blev lavet gradvist med expand, backfill, verify, enforce og contract. Det gjorde at gammel og ny kode kunne fungere samtidig under overgangen. Verification viste også at ticket prices og currencies forblev uændrede.

## Two decisions worth discussing

En beslutning var at håndhæve vigtige ticket-regler med database constraints i stedet for kun i applikationen. Alternativet var at lade applikationen stå for kontrollen. Database constraints passer godt her, fordi ugyldige writes bliver afvist uanset hvilken kode der skriver til databasen. Lecture 2 viser constraints og rejected writes.

En anden beslutning var at ændre product identity gradvist i stedet for at droppe `product_code` direkte. En direkte ændring fejlede på eksisterende data. Den gradvise migration gjorde det muligt at backfille eksisterende tickets og holde gammel og ny kode kompatibel under ændringen.

## One limitation or open question

Database constraints kan ikke sikre alle regler i systemet. Et eksempel er concurrent seat reservations, hvor to køb kan forsøge at tage den sidste plads samtidig. Det er beskrevet i Lecture 2 integrity map. Næste skridt ville være at teste reservationen med samtidige transactions og undersøge hvilken locking eller isolation der skal bruges.
