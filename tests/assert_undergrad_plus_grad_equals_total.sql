-- Reconciliation check: undergrad + grad should equal the grand total.
-- Returns the institutions where it doesn't. Set to warn, because finding out
-- *why* some rows don't tie out is the interesting part.

{{ config(severity = 'warn') }}

select
    institution_year_key,
    institution_name,
    total_enrolled,
    undergrad_enrolled,
    grad_enrolled,
    total_enrolled - (coalesce(undergrad_enrolled, 0) + grad_enrolled) as difference

from {{ ref('fct_enrollment_by_institution_year') }}
where total_enrolled is not null
  and total_enrolled <> coalesce(undergrad_enrolled, 0) + grad_enrolled
