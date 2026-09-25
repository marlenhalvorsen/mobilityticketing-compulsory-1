# Integrity map

| Invariant                                                       | Classification             | Affected tables and columns                    | Current protection               | Missing protection or limitation             | Expected failure behaviour                                                       | Evidence                     |
| --------------------------------------------------------------- | -------------------------- | ---------------------------------------------- | -------------------------------- | -------------------------------------------- | -------------------------------------------------------------------------------- | ---------------------------- |
| Product price cannot be negative                                | Direct constraint          | products.price                                 | CHECK constraint                 | NULL is still possible                       | An insert or update with a negative price should be rejected                     | See constraint test evidence |
| Ticket price cannot be negative                                 | Direct constraint          | tickets.price                                  | CHECK constraint                 | NULL is still possible                       | An insert or update with a negative price should be rejected                     | See constraint test evidence |
| Reserved seats must be between 0 and capacity                   | Direct constraint          | trips.reserved_seats, trips.capacity           | CHECK constraint                 | Does not handle concurrent seat purchases    | A value below 0 or above capacity should be rejected                             | See constraint test evidence |
| Ticket code must be unique                                      | UNIQUE or exclusion rule   | tickets.ticket_code                            | UNIQUE constraint                | NULL is still possible                       | A duplicate ticket code should be rejected                                       | See constraint test evidence |
| Ticket validity cannot end before it starts                     | Direct constraint          | tickets.valid_from_utc, tickets.valid_to_utc   | CHECK constraint                 | NULL values are still possible               | A validity period where valid_to_utc is before valid_from_utc should be rejected | See constraint test evidence |
| Capacity cannot be negative                                     | Direct constraint          | trips.capacity                                 | CHECK constraint                 | None                                         | An insert or update with negative capacity should be rejected                    | See constraint test evidence |
| Payment must reference an existing ticket                       | Direct constraint          | payments.ticket_id                             | FOREIGN KEY constraint           | NULL is still possible                       | A payment referencing an unknown ticket should be rejected                       | See constraint test evidence |
| Status must be one of the accepted statuses                     | Direct constraint | tickets.status, payments.status                | CHECK constraint                             | None | Unknown status should be rejected                    | CHECK constraint     |
| Validation ticket ID and ticket code must match the same ticket | Direct constraint          | validations.ticket_id, validations.ticket_code | Composite FOREIGN KEY constraint | NULL values are still possible               | A mismatched ticket_id and ticket_code should be rejected                        | See constraint test evidence |
| Ticket must reference an existing trip                          | Direct constraint          | tickets.trip_id                                | FOREIGN KEY constraint           | NULL is still possible                       | A ticket referencing an unknown trip should be rejected                          | See constraint test evidence |

## Issue register

### Issue 1 - Concurrent seat reservations

- Evidence: reserved_seats cannot be greater than capacity with the current CHECK constraint.
- Problem: Two purchases could happen at the same time and both try to reserve the last available seat.
- Consequence: A CHECK constraint alone cannot control concurrent purchases.
- Specific improvement: Handle seat reservation inside a transaction with appropriate locking.
- Open question: How should concurrent purchases for the last available seat be handled?

### Issue 2 - External payment

- Evidence: Payments contain an external_payment_reference from the payment provider.
- Problem: The database cannot guarantee that an external payment was actually captured by the payment provider.
- Consequence: The database and payment provider could disagree about the payment state.
- Specific improvement: Handle payment and database updates through a controlled transaction/workflow.
- Open question: What should happen if payment succeeds externally but the database update fails?


## State-transition trace

### Ticket purchase

1. A ticket row is created and references an existing user, trip and product.
2. A payment row is created and references the user and ticket.
3. The trip reserved_seats value is increased when the purchase reserves a seat.

### Ticket validation

1. The ticket is found using its ticket identity.
2. A validation row is created with the matching ticket_id and ticket_code.
3. The ticket status may be updated after a successful validation.


# Constraint test evidence

## Test 1 - Negative capacity

Invalid write: capacity = -1 was rejected.
Constraint: trips_capacity_non_negative
Result: CHECK violation. SQLSTATE: 23514.

## Test 2 - Reserved seats above capacity

Invalid write: reserved_seats = capacity + 1 was rejected.
Constraint: trips_reserved_seats_valid
Result: CHECK violation. SQLSTATE: 23514.

## Test 3 - Unknown trip

Invalid write: Ticket referencing TRIP-DOES-NOT-EXIST was rejected.
Constraint: tickets_trip_fk
Result: FOREIGN KEY violation. SQLSTATE: 23503.

## Test 4 - Reversed validity window

Invalid write: valid_to_utc before valid_from_utc was rejected.
Constraint: tickets_validity_window
Result: CHECK violation. SQLSTATE: 23514.

## Test 5 - Duplicate ticket code

Invalid write: Duplicate ticket_code was rejected.
Constraint: tickets_ticket_code_unique
Result: UNIQUE violation. SQLSTATE: 23505.

## Test 6 - Unknown ticket status

Invalid write: status = 'Unknown' was rejected.
Constraint: tickets_status_valid
Result: CHECK violation. SQLSTATE: 23514.

## Test 7 - Negative product price

Invalid write: price = -1 was rejected.
Constraint: products_price_non_negative
Result: CHECK violation. SQLSTATE: 23514.

## Test 8 - Payment for unknown ticket

Invalid write: Payment referencing NO-SUCH-TICKET was rejected.
Constraint: payments_tickets_fk
Result: FOREIGN KEY violation. SQLSTATE: 23503.

## Test 9 - Duplicate payment reference

Invalid write: Duplicate external_payment_reference was rejected.
Constraint: payment_external_payment_reference_unique
Result: UNIQUE violation. SQLSTATE: 23505.

## Test 10 - Mismatched ticket identity

Invalid write: Mismatched ticket_id and ticket_code was rejected.
Constraint: validations_ticket_id_ticket_code_fk
Result: FOREIGN KEY violation. SQLSTATE: 23503.
