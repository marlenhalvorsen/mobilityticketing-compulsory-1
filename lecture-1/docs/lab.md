# Lecture 1 implementation lab

## Purpose

Build the smallest relational model that supports route maintenance and upcoming-trip queries. The implementation is not expected to represent the complete MobilityTicketing platform. It should make your modelling assumptions executable.

## Work in this lecture

1. Create tables for operators, routes, stops, route stops, and trips.
2. Decide the primary key of the route-stop relation and explain the decision.
3. Add primary-key and foreign-key relationships.
4. Insert the supplied seed data.
5. Write the three workload queries in `database/postgres/003_queries.sql.example`.
6. Compare the implemented schema with your ER diagram and record any difference.

## Workload queries

1. Show the next 20 scheduled trips for a route after a supplied timestamp.
2. Show the ordered stops belonging to a route.
3. Show all routes and the number of scheduled trips on a supplied service date, including routes with no trips.

## Do not implement yet

Do not add MongoDB, Redis, caching, event queues, payment logic, validation logic, reporting tables, or performance indexes. Those decisions are introduced later.

## Required evidence

- A schema that can be recreated from an empty database.
- Seed data that can be loaded more than once without manual editing.
- The three queries and representative results.
- A short note identifying one modelling assumption that may change later.
- A system context, access-pattern map, ER diagram, and one functional dependency note.

## System context

MobilityTicketing is a city transport system for customers and transport operators.

Customers can search for routes and trips and buy tickets for travelling.

Operators manage routes, stops, timetables and scheduled trips. They are also responsible for ticket validation.


For this implementation the focus is on operators, routes, stops, route stops and trips.

## Access-pattern map

| Access pattern         | Actor    | Description                              |
| ---------------------- | -------- | ---------------------------------------- |
| Route search           | Customer | Search for routes and upcoming trips     |
| Ticket purchase        | Customer | Buy a ticket for a trip                  |
| Ticket validation      | Operator | Validate a ticket when travelling        |
| Timetable updates      | Operator | Update routes, stops and scheduled trips |
| Real-time availability | Customer | See current availability and changes     |
| Reporting              | Operator | Use trip and route data for reports      |

Only route maintenance and scheduled trips are implemented for now.

## ER diagram

The ER diagram can be found in er-diagram.puml.

## Functional dependency and normalization

One functional dependency is:

route.id -> operator_id, city_id, mode, short_name

The route ID identifies a route and determines the other attributes of that route.

Normalization helps prevent duplicate data. For example, operator information is stored separately instead of repeating the operator information for every route.

## Schema comparison

The SQL schema and ER diagram use the same entities and relationships.

route_stops uses (route_id, stop_sequence) as a composite primary key. stop_sequence represents the position of a stop on a route. This also means the same stop can appear more than once on the same route at different positions.

There are currently no differences between the ER diagram and the implemented schema.

## Implementation scope

The current implementation supports operators, routes, stops, ordered route stops and scheduled trips.

It supports the three required queries for upcoming trips, ordered stops and the number of scheduled trips on a given date.

Customers, tickets, payments, ticket validation, real-time data and reporting are not implemented yet.

## Query results

The three workload queries were tested with the supplied seed data.

Query 1 returned the two scheduled M2 trips after the supplied timestamp.
Query 2 returned the stops for M2 in the correct stop sequence.
Query 3 returned both routes with 2 scheduled trips each on 2026-08-01.


## Submission checklist

- [x] Describe the customers, operators, and city transport context without naming a database product.
- [x] Cover route search, ticket purchase, ticket validation, timetable updates, real-time availability, and reporting in the access-pattern map.
- [x] Include identifiers, relationships, and cardinalities in the ER diagram.
- [x] Explain one functional dependency and what normalization prevents.
- [x] State what the implementation proves and what remains unknown.
- [x] Commit the implementation under `database/postgres/`.
