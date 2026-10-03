# spacsysr 0.2.0

- New: Farquhar C3 / Yin & Struik C4 leaf photosynthesis + canopy
  sun/shade integration (manual ch. 2.2).
- New: 1-D Richards equation solver (Brooks-Corey / van Genuchten,
  Picard + Thomas), soil heat conduction, annual-wave lower BC
  (manual ch. 6-7).
- Note: manual eq. 301 (VG-Mualem) as printed differs from the standard
  Mualem form and is flagged "check against code"; the standard form is
  implemented.

# spacsysr 0.1.0

- First release: core SPACSYS soil biogeochemistry modules in pure base R.
- Response functions (Q10, moisture, WFPS, pH, Michaelis-Menten, inhibitor).
- SOM decomposition; simplified + microbiological nitrification/denitrification.
- N2O/NO emissions, NH3 volatilisation, CH4 production/oxidation.
- Plant respiration, tipping-bucket water balance, daily driver `spacsys_run()`.
- Bundled paddy example data and N2O vignette.
