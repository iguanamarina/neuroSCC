## R CMD check results

0 errors | 0 warnings | 0 notes

## Resubmission

This is a resubmission of `neuroSCC`.

The previous CRAN version was archived because it depended on `contoureR`, which is no longer available on CRAN.

In this update:

- the dependency on `contoureR` has been removed from `DESCRIPTION`;
- contour extraction has been reimplemented internally using base R;
- `neuroContour()` has been updated accordingly;
- documentation, examples, and vignettes have been revised to reflect the new behavior.

## Notes

All checks were run successfully with no errors, warnings, or notes.
