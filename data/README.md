## Known issues
- `zip_code` spells suburban as "Surburban" (typo in the source data); kept as-is so queries match the raw file.
- Two `history_segment` values contain commas (`6) $750 - $1,000`, `7) $1,000 +`), so they're quoted in the CSV.