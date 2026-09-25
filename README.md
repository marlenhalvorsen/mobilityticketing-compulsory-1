# Compulsory Assignment 1 review guide

Submitted commit: See Moodle submission

Setup og reset findes i README-filerne under de enkelte lectures.

## Where to find the work

Lecture 1 indeholder database model, seed data og queries. Modellen findes i `lecture-1/docs/er-diagram.puml`, schemaet i `lecture-1/database/postgres/001_relational_baseline.sql`, seed data i `002_seed.sql` og queries i `003_queries.sql.example`. Mine noter og arbejde fra labben findes i `lecture-1/docs/lab.md` og `notes.md`.

Lecture 2 indeholder arbejdet med constraints og integrity. Integrity migrationen findes i `lecture-2/database/postgres/migrations/011_ticketing_integrity.sql`, og tests af writes der skal fejle findes i `lecture-2/database/postgres/experiments/constraints_should_fail.sql`. Integrity map og lab findes under `lecture-2/docs/`.

Lecture 3 indeholder reporting experimentet. Reporting function, trigger og materialized view findes i migrationsfilerne `020_reporting_function.sql`, `021_daily_revenue_trigger.sql` og `022_daily_captured_revenue.sql`. Base query findes i `lecture-3/database/postgres/queries/base_revenue.sql`, og reporting tests findes i `experiments/reporting_cases.sql`. Resultaterne er dokumenteret i `lecture-3/docs/lab-results.md`.

Lecture 4 indeholder migrationen fra `product_code` til `product_id`. Migrationerne findes i `lecture-4/database/postgres/migrations/030_expand_product_identity.sql`, `031_backfill_ticket_product.sql` og `032_require_ticket_product.sql`. Old/new readers og writers, verification og removal test findes i `lecture-4/database/postgres/experiments/lecture04/`. Dokumentationen findes i `lecture-4/docs/lecture04.md`.

## Two decisions worth discussing

En beslutning var at håndhæve vigtige ticket-regler med database constraints i stedet for kun at stole på applikationen. Det betyder at ugyldige writes bliver afvist direkte af databasen. Tests af dette findes i Lecture 2.

En anden beslutning var at ændre product identity gradvist i stedet for at fjerne `product_code` direkte. Vi brugte expand, backfill, verify, enforce og contract. Det gjorde at gammel og ny kode kunne fungere samtidig under migrationen. Arbejdet og verification findes i Lecture 4.

## One limitation or open question

Database constraints kan beskytte de regler, som faktisk er defineret i schemaet, men de kan ikke automatisk sikre alle regler fra applikationen. Et spørgsmål er derfor hvilke regler der bør ligge i databasen, og hvilke der bør være applikationens ansvar.

