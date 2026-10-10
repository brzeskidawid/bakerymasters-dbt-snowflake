{{ config(materialized='table') }}

with p as (
    select * from {{ ref('stg_pracownicy') }}
)

select
    p.pracownik_id,
    p.pracownik,
    p.imie,
    p.nazwisko,
    p.plec,
    p.data_urodzenia,
    p.data_zatrudnienia,
    p.data_zwolnienia,
    p.stanowisko_id,
    p.dzial_id,
    p.kod_siatki,
    p.wymiar_etatu,
    p.typ_umowy,
    iff(p.data_zwolnienia is null, true, false)        as czy_aktywny,
    datediff('year', p.data_urodzenia, current_date()) as wiek,
    datediff(
        'month', p.data_zatrudnienia,
        coalesce(p.data_zwolnienia, current_date())
    )                                                  as staz_miesiace_total
from p
