# BakeryMasters - projekt dbt + Snowflake

Warstwa transformacyjna dla danych kadrowo-placowych BakeryMasters.
Zrodlo: `BAKERY.RAW` (8 tabel zaladowanych z CSV).
Cel: `BAKERY.ANALYTICS` - gotowe wymiary i fakty pod model semantyczny Power BI.

## Architektura

    RAW (zrodla)  ->  staging (widoki)  ->  intermediate (ephemeral)  ->  marts (tabele)  ->  Power BI

| Warstwa | Materializacja | Po co |
|---|---|---|
| `staging` | view | 1:1 do zrodla - tylko zmiana nazw, typow, oczyszczenie wartosci pustych. Zero logiki biznesowej. |
| `intermediate` | ephemeral | Kroki posrednie (CTE wkompilowane w model nadrzedny). Nie zajmuja miejsca w bazie. |
| `marts` | table / incremental | Warstwa dla odbiorcy. Wymiary i fakty gotowe do podpiecia pod model semantyczny. |

## Modele

**staging** - `stg_pracownicy`, `stg_lista_plac`, `stg_wartosciowanie`, `stg_bridge_wartosciowanie`,
`stg_kryteria`, `stg_siatka`, `stg_struktura_org`, `stg_kategorie_porownawcze`

**intermediate**
- `int_stanowisko_punkty` - przelicza wartosciowanie z mostka (stanowisko x podkryterium)
  na jedna liczbe punktow: suma (ocena x waga podkryterium)
- `int_lista_plac_wzbogacona` - lista plac + atrybuty pracownika, przeliczenie na pelny etat

**marts**
- `dim_stanowisko` - wymiar konformowany (uzywany przez fakt i agregat)
- `dim_pracownik`
- `dim_miesiac` - wymiar czasu wygenerowany z zakresu danych
- `fct_lista_plac` - **incremental**, merge po `lista_plac_id`, ziarno pracownik x miesiac
- `agg_luka_placowa` - skladniki luki placowej w ziarnie miesiac x stanowisko x plec

**snapshots**
- `snp_pracownicy` - SCD2 (strategia `check`) na slowniku pracownikow, bo zrodlo nadpisuje stan biezacy

## Podzial logiki: dbt vs Power BI

Regula: **jesli odpowiedz nie zalezy od tego, co uzytkownik kliknal - nalezy do warstwy danych.
Jesli zalezy - nalezy do DAX-a.**

W dbt: miary addytywne (kwoty, godziny, licznosci), przeliczenia na poziomie wiersza
(wynagrodzenie na pelny etat, staz), klucze, integralnosc, historia.

W DAX: wszystko, co jest ilorazem liczonym na zbiorze - srednia placa, mediana,
luka placowa w procentach, udzialy, porownania rok do roku. Te wielkosci sa nieadytywne:
sredniej nie da sie zsumowac po dzialach, trzeba ja przeliczyc dla kazdego kontekstu filtra.

Dlatego `agg_luka_placowa` dostarcza `suma_wynagrodzen_fte` i `liczba_pracownikow`,
a nie gotowy procent.

## Testy

Generic (w plikach `_*.yml`): `unique`, `not_null`, `relationships`, `accepted_values`,
`dbt_utils.unique_combination_of_columns`, `dbt_utils.accepted_range`.

Singular (katalog `tests/`):
- `assert_wynagrodzenie_calkowite_zgodne` - calkowite = zasadnicze + premia + dodatki
- `assert_brak_wyplat_poza_okresem_zatrudnienia` - brak wyplat przed zatrudnieniem i po zwolnieniu

## Uruchomienie

    dbt deps
    dbt build          # run + test + snapshot w kolejnosci DAG-u
    dbt docs generate  # dokumentacja + graf lineage

## Uruchomienie lokalne (dbt Core)

    pip install dbt-snowflake

Profil lokalny trzymamy POZA repo, w `~/.dbt/profiles.yml`
(Windows: `%USERPROFILE%\\.dbt\\profiles.yml`):

    default:
      target: dev
      outputs:
        dev:
          type: snowflake
          account: <identyfikator konta>
          user: <uzytkownik>
          password: <haslo>
          role: ACCOUNTADMIN
          database: BAKERY
          warehouse: DBT_WH
          schema: DBT_DEV
          threads: 8

Potem:

    dbt deps
    dbt debug          # test polaczenia
    dbt build          # run + test + snapshot w kolejnosci DAG-u
    dbt docs generate && dbt docs serve

## CI/CD (GitHub Actions)

Trzy workflowy, podzial wedlug kosztu sprawdzenia.

### `ci.yml` - na kazdym pull requescie

| etap | co sprawdza | hurtownia |
|---|---|---|
| 1. `lint` | styl SQL (sqlfluff, dialekt snowflake) | nie |
| 2. `parse` | zepsute `ref()`, bledy w YAML-ach, testy na nieistniejacych kolumnach, cykle w DAG-u | nie |
| 3. `build` | `dbt build` zmienionych modeli i ich potomkow | tak |

Etapy 1 i 2 nie potrzebuja zadnych sekretow i koncza sie w kilkadziesiat sekund.
Etap 3 rusza dopiero, gdy oba przejda (`needs: [lint, parse]`).

Etap 3 to **slim CI**:

    dbt build --target ci --select state:modified+ --defer --state ./prod_state --favor-state

- `state:modified+` - buduje tylko modele zmienione w tym PR oraz to, co z nich wynika
- `--defer --state` - modele nietkniete przez PR sa czytane z produkcji zamiast przebudowywane
- manifest produkcyjny pobierany jest artefaktem z ostatniego udanego `deploy.yml`
- wszystko ladowane do tymczasowego schematu `PR_<numer>`, nigdy do `ANALYTICS`

### `deploy.yml` - po mergu do `main` (oraz codziennie o 4:00 UTC)

Pelny `dbt build --target prod`, potem `dbt docs generate`.
Publikuje `manifest.json` jako artefakt `prod-manifest` - to z niego korzysta slim CI.

### `pr-cleanup.yml` - po zamknieciu PR

`drop schema if exists BAKERY.PR_<numer> cascade`.
Bez tego po kilkunastu PR-ach baza zarasta schematami.

### Sekrety do ustawienia

GitHub -> Settings -> Secrets and variables -> Actions:

| sekret | przykladowa wartosc |
|---|---|
| `SNOWFLAKE_ACCOUNT` | `abcdefg-hi12345` |
| `SNOWFLAKE_USER` | nazwa uzytkownika |
| `SNOWFLAKE_PASSWORD` | haslo |
| `SNOWFLAKE_ROLE` | `ACCOUNTADMIN` |
| `SNOWFLAKE_DATABASE` | `BAKERY` |
| `SNOWFLAKE_WAREHOUSE` | `DBT_WH` |

Profil dla CI (`ci/profiles.yml`) jest w repo, ale nie zawiera zadnych danych
logowania - wylacznie `env_var()`.
