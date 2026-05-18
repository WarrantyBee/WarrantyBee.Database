---
name: warrantybee-database-migration
description: >-
  Runs and validates WarrantyBee database migrations via Run-Migration.ps1,
  dependencies.json ordering, and output.sql execution. Use when migrating schema,
  fixing build order, adding stored procedures, or troubleshooting migration failures.
---

# Database Migration Workflow

## Generate output

```powershell
cd WarrantyBee.Database
powershell -ExecutionPolicy Bypass -File .\Run-Migration.ps1 -skipdata -db warrantybeedev
```

Produces `output.sql` at repo root.

## Apply

1. MySQL Workbench → connect as `root`
2. Open `output.sql` → execute (creates DB + objects)
3. Run seed `data.sql` files in order (see wiki Developer-Setup)

## dependencies.json

Topological sort uses:

- `functions.master` / `functions.business`
- `procedures.master` / `procedures.business`

When adding `usp_NewProc`, declare all `ufn_*` and `usp_*` it calls. **Circular deps = build failure.**

## Troubleshooting

| Symptom | Check |
|---------|--------|
| Proc not found | Dependency order; proc file merged in output? |
| FK fails | Parent table created first in `objects.sql` |
| Duplicate object | DROP PROCEDURE IF EXISTS at top of column scripts |
| Syntax error | `DELIMITER $$` blocks closed properly |

## PR checklist

- [ ] `output.sql` regenerated (if team tracks it) OR CI regenerates
- [ ] No machine-specific passwords in committed SQL
- [ ] `resources.dbml` reflects new tables
- [ ] Wiki updated for new procs/tables

## Pair with API

List every new/changed `in_*` parameter for API repository updates in PR description.
