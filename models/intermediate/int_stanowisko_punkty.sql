{{ config(materialized='ephemeral') }}

-- Przelicza wartosciowanie pracy z poziomu ocen czastkowych (mostek)
-- na jedna liczbe punktow per stanowisko: suma (ocena x waga podkryterium).
-- Dzieki temu wynik_wartosciowania z pliku zrodlowego mozna niezaleznie zweryfikowac.

with bridge as (
    select * from {{ ref('stg_bridge_wartosciowanie') }}
),

kryteria as (
    select * from {{ ref('stg_kryteria') }}
),

polaczone as (
    select
        b.stanowisko_id,
        k.kryterium_glowne,
        k.podkryterium,
        k.waga_podkryterium,
        b.ocena,
        b.ocena * k.waga_podkryterium as punkty_wazone
    from bridge as b
    inner join kryteria as k
        on b.podkryterium = k.podkryterium
),

per_stanowisko as (
    select
        stanowisko_id,
        round(sum(punkty_wazone), 3)                                             as punkty_laczne,
        round(sum(iff(kryterium_glowne = 'Warunki pracy', punkty_wazone, 0)), 3) as punkty_warunki_pracy,
        count(*)                                                                 as liczba_podkryteriow
    from polaczone
    group by 1
)

select * from per_stanowisko
