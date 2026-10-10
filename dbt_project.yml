name: 'bakerymasters'
version: '1.0.0'
config-version: 2

profile: 'default'

model-paths: ["models"]
snapshot-paths: ["snapshots"]
test-paths: ["tests"]
macro-paths: ["macros"]
seed-paths: ["seeds"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  bakerymasters:
    staging:
      +materialized: view
    intermediate:
      +materialized: ephemeral
    marts:
      +materialized: table
      # Nazwy plikow trzymaja konwencje dbt (dim_ / fct_), ale obiekty widoczne
      # w Snowflake i w Power BI dostaja aliasy w konwencji domowej (D_ / F_).
      # Nazewnictwo wewnetrzne projektu to jedno, kontrakt z odbiorca to drugie.
      dim_calendar:
        +alias: D_Calendar
      dim_pracownik:
        +alias: D_Pracownik
      dim_stanowisko:
        +alias: D_Stanowisko
      fct_lista_plac:
        +alias: F_Lista_Plac
      agg_luka_placowa:
        +alias: F_Luka_Placowa
