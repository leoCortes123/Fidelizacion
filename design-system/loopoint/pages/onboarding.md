# Onboarding Page Overrides

> **PROJECT:** Loopoint
> **Generated:** 2026-11-10 20:12:12
> **Page Type:** General

> ⚠️ **IMPORTANT:** Rules in this file **override** the Master file (`design-system/MASTER.md`).
> Only deviations from the Master are documented here. For all other rules, refer to the Master.

---

## Page-Specific Rules

### Layout Overrides

- **Max Width:** 1200px (standard)
- **Layout:** Full-width sections, centered content
- **Sections:** Hero > Step 1 (problem) > Step 2 (solution) > Step 3 (action) > CTA progression

### Spacing Overrides

- No overrides — use Master spacing

### Typography Overrides

- No overrides — use Master typography

### Color Overrides

- **Strategy:** Step colors: 1 (Red/Problem), 2 (Orange/Process), 3 (Green/Solution). CTA: Brand color

### Component Overrides

- Avoid: Force linear unskippable tour
- Avoid: No indication of progress
- Avoid: Promise an exact final line or insert blanket nonbreaking spaces or hardcoded br tags

---

## Page-Specific Components

- No unique components for this page

---

## Recommendations

- Effects: Inner+outer shadows (subtle, no hard lines), soft press (200ms ease-out), fluffy elements, smooth transitions
- Onboarding: Provide Skip and Back buttons
- Feedback: Step indicators or progress bar
- Typography: Bound the measure and test natural-wrap fallback across widths fonts and locales
- CTA Placement: Each step: mini-CTA. Final: main CTA
