# Evidence retention

Evidence is a factual record, not a second source of engineering policy. Keep dated command baselines, approved screenshot metadata, configuration details, and known limitations here. Every emulator/simulator screenshot captured with `scripts/device_matrix.sh` has a sibling JSON sidecar containing the validated runtime `MediaQuery` data and non-identifying capture metadata. Do not retain secrets, user data, serials, device identifiers, raw production logs, or unapproved reference assets.

