---
name: warrantybee-database-schema
description: >-
  Designs and implements WarrantyBee MySQL tables, constraints, foreign keys, and
  triggers using the procedural DDL framework. Use when adding tbl_* tables, columns,
  vendor entities, RBAC seeds, or updating resources.dbml.
---

# Database Schema Workflow

## Design first

1. Add table to `resources.dbml` (relationships + notes).
2. Confirm FK order in `objects.sql`.
3. Identify which roles/permissions need new seed rows.

## Implementation

### 1. Create table folder

`src/tables/tblMyEntity/` — columns, constraints, foreignkeys, triggers.

### 2. columns.sql

Use `usp_AddColumn` with `v_required` / `v_optional` flags. Call `usp_CreateTable` at end of `objects.sql` chain (via `objects.sql` entry).

### 3. constraints.sql

- Unique keys via `usp_CreateUniqueKey`
- Checks via `usp_AddCheck` (CHAR_LENGTH, numeric ranges)

### 4. foreignkeys.sql

Use `usp_CreateForeignKey` — parent table must exist earlier in migration order.

### 5. triggers

`before_insert` / `before_update`: maintain `updated_at`, validate cross-field rules if not in CHECK.

### 6. data.sql (optional)

Only lookup/reference. Use `INSERT` with stable IDs where API depends on fixed role/permission codes.

## Post-change

- [ ] `dependencies.json` updated
- [ ] Regenerate `output.sql` and smoke-test
- [ ] Update `WarrantyBee.Database.wiki/Tables.md` section
- [ ] Notify API team of new `usp_*` contract

## Anti-patterns

- Hard DELETE on user/vendor rows
- Missing `void` column
- FK without index
- Business logic only in API that should be invariant in DB
