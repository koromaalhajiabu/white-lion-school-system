# White Lion Cloud Schema Completion Plan

**Status: preparation only — no live database changes made.**  
Project: `homvrbxfwacopbnhujyg`  
Scope: `public.wl_students`, `public.wl_attendance`, `public.wl_grades`, `public.wl_fees`

## Safety rules

1. Run `complete-schema-audit.sql` first and retain its results.
2. Do not rename or drop existing columns, change existing types, or add constraints until the live column inventory and current records have been reviewed.
3. Do not add foreign keys until the exact student key types and existing orphan records have been checked.
4. Do not enable browser cloud sync until policies, grants, and the application's actual data fields have been validated.
5. Never put a Supabase service-role/secret key in the HTML, GitHub repository, or browser.
6. Keep the existing localStorage records and JSON backup intact. A cloud-table count of zero does not mean the device has no records.

## Required completion sequence

- [ ] Capture exact columns, types, defaults, nullability, constraints, indexes, RLS policies, and grants from the live project.
- [ ] Compare live columns against the portal's actual record shapes.
- [ ] Decide and document the canonical student identifier and how it maps to attendance, grades, and fees.
- [ ] Check duplicates, null required values, invalid dates/scores/amounts, and orphan references before adding constraints.
- [ ] Prepare a forward-only migration with explicit preconditions and a rollback plan; do not silently drop or rewrite data.
- [ ] Apply the migration only after reviewing the generated SQL and taking a database backup.
- [ ] Test as anonymous, authenticated non-developer, and the authorized developer; verify least-privilege access.
- [ ] Test cloud sync using disposable test records first, including offline edits, retry behavior, conflict handling, and duplicate prevention.
- [ ] Keep real student records local until a deliberate, backed-up migration/import is approved and verified.

## Table responsibilities (provisional; confirm against actual columns)

| Table | Intended role | Important checks before completion |
|---|---|---|
| `wl_students` | Student master records | Admission-number uniqueness, required name, student ID type |
| `wl_attendance` | Daily attendance | Student key type, date format, allowed status values, duplicate student/date rows |
| `wl_grades` | Assessment results | Student key type, score bounds, maximum score > 0, term/subject conventions |
| `wl_fees` | Fee obligations/payments | Student key type, nonnegative amounts, paid amount vs due amount, payment-history needs |

This table is a design checklist, **not a claim about the live schema**. Do not apply guessed columns or constraints.

## What is still needed to produce the exact migration

The read-only audit result from the target Supabase project's SQL Editor. It returns metadata and row counts only, not student names or financial records. Once that result is available, the migration can be written against the actual schema rather than guessed.
