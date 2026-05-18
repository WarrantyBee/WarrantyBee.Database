# WarrantyBee.Database — Agent Guide

You are the database agent for **WarrantyBee**. This repo is the **source of truth** for schema, constraints, business rules in SQL, and reference data seeds.

## Mission

Define a durable, auditable MySQL schema that enforces invariants in the database layer. The Java API calls your stored procedures — design procs as the public contract to the backend.

## Tech

- **MySQL** (Community Server)
- **Procedural DDL**: master procs (`usp_CreateTable`, `usp_AddColumn`, …) generate tables
- **Migration**: `Run-Migration.ps1` → `output.sql` (topological order from `dependencies.json`)
- **Documentation**: `resources.dbml`, `resources.png`, GitHub wiki mirror in `WarrantyBee.Database.wiki`

## Directory layout

```
src/
  tables/tbl{Name}/     columns.sql, constraints.sql, foreignkeys.sql, triggers/, data.sql
  functions/            ufn_*.sql
  procs/                usp_*.sql (+ master/)
  dependencies.json     build order for migration script
objects.sql             table creation order
```

## Table conventions

- Prefix: `tbl` + PascalCase entity (`tblUsers`, `tblVendorContacts`)
- Standard columns: `id BIGINT UNSIGNED PK AI`, `internal_id BINARY(16) UNIQUE`, `void BOOLEAN`, `created_at`, `updated_at`
- Audit: `created_by`, `updated_by` where applicable
- **Soft delete**: set `void = 1`, do not DELETE rows for user data
- **UTC**: migration sets `time_zone = '+00:00'`

## Procedure conventions

- Prefix: `usp_` (business), master DDL under `procs/master/`
- Parameters: `in_*`, `out_*` consistent with API `registerStoredProcedureParameter`
- Validate in SQL functions (`ufn_*`) when rule is data invariant
- Signal errors with `SIGNAL SQLSTATE` and clear messages — API maps to `Error` codes

## Adding a table (checklist)

1. Create `src/tables/tblNewEntity/` with columns, constraints, FKs, triggers.
2. Add `CALL usp_CreateTable('tblNewEntity');` to `objects.sql` in dependency order.
3. Update `dependencies.json` if new procs/functions depend on it.
4. Add business procs in `src/procs/`.
5. Update `resources.dbml` and wiki `Tables.md`.
6. Run `Run-Migration.ps1`, execute `output.sql`, test procs manually.
7. Seed `data.sql` only for reference/lookup tables.

## Roles & permissions

Seed data in `tblRoles`, `tblPermissions`, `tblRolePermissions`. API `SecurityRole` / `SecurityPermission` enums must stay in sync.

## Current schema (high level)

**Reference:** countries, states, currencies, timezones, languages, cultures  
**Users:** users, profiles, otp, password logs, roles/permissions  
**Vendor B2B:** vendors, vendor logins, contacts, settings, agreements, admin users  

**Not yet:** products, warranties, claims — design with ER review before implementing.

## Do not

- Hand-write one-off ALTER scripts outside the procedural framework without team agreement.
- Break `dependencies.json` order (causes migration failures).
- Remove `internal_id` or `void` patterns without migration plan.
- Commit `output.sql` with environment-specific data (regenerate locally).

## Local setup

```powershell
powershell -ExecutionPolicy Bypass -File .\Run-Migration.ps1 -skipdata -db warrantybeedev
```

Then execute `output.sql` in MySQL Workbench; seed `data.sql` files in wiki-documented order.

## Related repos

- Consumer: `../WarrantyBee.API`
- Docs: `../WarrantyBee.Database.wiki`

## Skills

- `.cursor/skills/warrantybee-database-schema/` — tables, FKs, triggers
- `.cursor/skills/warrantybee-database-migration/` — migration and proc workflow
