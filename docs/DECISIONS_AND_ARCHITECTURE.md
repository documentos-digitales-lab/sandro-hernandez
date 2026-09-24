# Decisions & Architecture

This document explains the intentional decisions behind the implementation and
how the application is architected, separating deliberate trade-offs from
accidental complexity. It is written in English to match the repository
language; a Spanish version can be provided on request.

## Intentional decisions

### 1. Authentication is RFC-based, without a password (conscious)

The exercise endpoints are unauthenticated and each `Customer` is identified by
its RFC — a public identifier in Mexico. We treat "knowing the RFC" as the
credential:

- Registered customers sign in by typing their RFC; there is no separate
  password, no hashing and no lockout.
- `Session` is stored in a signed (not encrypted) cookie holding only
  `customer_id` and the cached display profile.
- **Why**: adding full authentication is out of scope for this exercise, keeps
  the demo frictionless, and the team reviewed the trade-off. In production
  this would be replaced by BCrypt credentials + rate limiting, which we
  document as a known limitation.

### 2. Single source of truth for money math, with persisted (denormalized) totals

- `InvoiceTaxCalculator` is the **only** place in Ruby that computes
  amounts, subtotal, tax (16%) and total.
- The invoice model **persists** `subtotal`, `tax` and `total` in a
  `before_save` hook (`Invoice#persist_totals`).
- `invoices#index` and `invoices#show` **read the persisted columns** — the DB
  is the authoritative read path for displayed totals; nothing is recomputed
  per row during rendering.
- **Why**: persisted totals make list queries (and future reporting/analytics)
  cheap and stable, while a single calculator keeps the math DRY. The
  trade-off is denormalization drift risk, which is acceptable here because
  invoices (and their items) are immutable after creation.

### 3. Business rules are environment-driven, with code-free defaults

Two values that may change over time live in the environment, with defaults
that keep the app working when the variables are absent:

| Variable | Meaning | Default |
| --- | --- | --- |
| `INVOICE_TAX_RATE` | tax percentage (as decimal) | `0.16` |
| `ADDITIONAL_TAXES_THRESHOLD` | per-product tax amount that triggers the warning | `2000` |

They are read from `InvoiceConfig`, a small facade over `ENV.fetch`, so no code
changes are needed if these business numbers change later. In development and
test, `dotenv-rails` loads them from a local `.env` file (gitignored); a
documented template lives in `.env.example`.

### 4. The JavaScript preview is not a second source of truth

`invoice_form_controller.js` (Stimulus) shows live amounts on the client, but
the authoritative math lives server-side. The JS receives the business rules —
tax rate, high-tax threshold and the warning messages — via `data-*` attributes
read from the same services (`InvoiceConfig`), so the preview and the backend
cannot drift apart.

The submitted values are validated and recomputed server-side at save time.

### 5. The external profile is fetched lazily and degrades gracefully

Login does **not** block on the third-party API. `ApplicationController` runs a
`load_user_profile` callback that:

1. Bails out when there is no logged-in customer or the profile is already
   cached in the session.
2. Otherwise calls `UserProfileLoader` → `ExternalUserClient` (`Net::HTTP`,
   HTTPS + CA verification, 2s/3s timeouts) for `https://dummyjson.com/users/<customer.id>`.
3. Caches the result in the session for the rest of the session lifetime.
4. On **any** failure (`ExternalUserClient::Error` wraps timeouts, sockets and
   SSL errors) stores an empty profile and the UI falls back to showing the RFC.

This removes slow HTTP from the authentication hot path and keeps the app
usable when the API is down.

### 6. The HTTP client is injected (dependency inversion)

`UserProfileLoader.call(customer_id:, client: ExternalUserClient)` takes the
client as a collaborator. Tests inject a fake client, and none of the
synchronous HTTP stack is coupled to the service's customers.

### 7. Tenant boundaries are enforced by scoping, not by trusting params

Every invoice lookup goes through `current_customer.invoices.find_by!(...)`,
so cross-customer reads raise `ActiveRecord::RecordNotFound` (covered by specs).
Public URLs identify invoices by `uuid` (not sequential ids), and
`customers#show` validates the `:id` against the logged-in customer, redirecting
to the canonical dashboard otherwise.

### 8. Test suite is deterministic and database-safe

- **RSpec + FactoryBot + Shoulda** for models/controllers/requests; Capybara for
  feature specs; **Selenium (headless Chrome)** for the interactive invoice-form
  preview (the core deliverable of Part 1), which rack-test cannot cover.
- **DatabaseCleaner**: `:transaction` for standard specs, `:truncation` around
  `type: :system` specs (the app server uses a separate DB connection so
  transactions cannot isolate it). The suite also truncates **before and
  after** the entire run: the test DB is guaranteed to be empty after running
  the tests.
- **Bullet** runs with `raise = true` in test and alerts in development, so
  N+1 and unused eager-loading fail the suite.

### 9. N+1 handling for the invoice list

`invoices#index` paginates with **Pagy** and renders **persisted** totals. The
product count per invoice is fetched in a single aggregate query
(`Item.where(invoice_id: page_ids).group(:invoice_id).count`) instead of loading
every item row, which keeps the query count flat regardless of page size.

### 10. Minimal dependency footprint

- No external HTTP gem — the standard library `Net::HTTP` is enough for one GET
  with timeouts.
- Bootstrap and Toastify are loaded from a CDN to avoid a front-end build
  toolchain; Stimulus ships via importmap.
- No background-job infrastructure was added; the profile fetch is lazy and
  cached, which removes the need for one at this scale.

### 11. Idempotent seed data

`db/seeds.rb` inserts a demo customer + invoice safely on repeated runs so a
reviewer can explore the flow immediately.

## Architecture

### Request lifecycle

```
Browser
  │  cookie (session: customer_id, user_profile)
  ▼
ApplicationController
  ├─ before_action :require_customer      → redirect to /session/new if logged out
  ├─ before_action :load_user_profile     → lazy API fetch + cache + welcome toast (once)
  │
  ▼
Controller (Sessions / Customers / Invoices)
  ▼
Services (calculation, rules, external API)
  ▼
Models → MySQL
```

### Layers

```
app/controllers       thin HTTP layer: params, redirects, rendering
app/services          business rules and integrations
  ├─ InvoiceTaxCalculator      amounts → subtotal / tax / total (the single calculator)
  ├─ AdditionalTaxesChecker    high-tax rule (> threshold per product)
  ├─ InvoiceConfig             environment-driven numbers (ENV.fetch + defaults)
  ├─ ExternalUserClient        Net::HTTP wrapper (HTTPS, timeouts, typed errors)
  ├─ UserProfileLoader         orchestrates client + builds UserProfile (injected client)
  └─ UserProfile               value object (real / Null)
app/models             persistence, validations, callbacks
app/javascript         Stimulus controllers (preview + toasts)
```

### Data model

```
customers 1───* invoices 1───* items
  · rfc (unique, normalized to uppercase)
  · invoices have: uuid (public id, indexed lookup),
                   subtotal, tax, total (persisted), items nested via
                   accepts_nested_attributes_for (reject_if :unused_item?)
  · items: description, quantity (> 0), unit_price (>= 0)
```

### Create-invoice flow

1. `GET /invoices/new` builds an invoice with two default rows
   (`quantity: 1` and the unused placeholder `quantity: 0`).
2. The user edits the rows; the Stimulus preview recomputes amounts, subtotal,
   tax, total and the high-tax warning live using server-provided rules.
3. `POST /invoices` applies `reject_if :unused_item?` (drops quantity-0 rows),
   runs validations (at least one product, per-item presence/numericality),
   computes and **persists** the totals in `before_save`, and redirects to the
   invoice page.
4. `invoices#show` renders the persisted totals and the additional-taxes
   banner, scoped to the current customer and keyed by `uuid`.

### Profile flow

```
POST /session  → set session[:customer_id], redirect to dashboard (no HTTP)
first authed render → load_user_profile
  ├─ success → session[:user_profile] = {full_name, image_url}
  │            flash.now[:welcome]  (single toast, consumed in that request)
  └─ error   → session[:user_profile] = empty → navbar shows "RFC: …"
```

### Testing strategy

| Layer | Tool | What it covers |
| --- | --- | --- |
| Models | RSpec + Shoulda | validations, callbacks, persisted totals, uuid, dependent destroy |
| Services | RSpec | calculator math, high-tax rule, ENV config, external client, loader with injected fakes |
| Controllers | RSpec controller specs | auth redirects, params, scoping, 404s |
| Requests | RSpec request specs | full HTTP flow incl. auth + lazy profile + toasts |
| Features | Capybara (rack-test) | registration → login → create invoice → list |
| System | Capybara + Selenium (headless Chrome) | interactive form preview, banner and submit guard (Part 1) |

## Known limitations (accepted trade-offs)

- RFC as the only credential, no rate limiting on login (see decision 1).
- Session cookie is signed but not encrypted; it stores no secrets (only ids and
  display data).
- No Content-Security-Policy configured (CDN assets + inline
  `data-*` values would need an allow-list). `csp_meta_tag` is present but no
  policy is enforced.
- The demo seed's API lookup relies on `dummyjson` users `<customer.id>`; on a
  brand-new database the seeded customer gets id 1 (works), while an existing
  non-empty table could map to an id outside the API's user range and fall back
  to the RFC display (graceful by design).
- `bin/setup` prepares the database but does not run `db:seed`; run it manually
  if you want the demo data.

## Development

```shell
bin/setup                        # installs deps + prepares DB
bin/rails server                 # values come from .env (dotenv-rails) or ENV
bin/rails db:seed                # optional demo data
bundle exec rspec                # full suite (Selenium system specs included)
```

Local overrides live in `.env` (copy `.env.example`, gitignored). The suite
expects the default values, so restore `0.16` / `2000` before running it.