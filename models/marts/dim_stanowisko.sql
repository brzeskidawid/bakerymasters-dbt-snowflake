{{ config(materialized='table') }}

with w as (
    select * from {{ ref('stg_wartosciowanie') }}
),

punkty as (
    select * from {{ ref('int_stanowisko_punkty') }}
),

siatka as (
    select * from {{ ref('stg_siatka') }}
),

dzialy as (
    select * from {{ ref('stg_struktura_org') }}
),

kategorie as (
    select * from {{ ref('stg_kategorie_porownawcze') }}
)

select
    w.stanowisko_id,
    w.stanowisko,
    w.dzial_id,
    d.dzial,
    d.pion,
    d.lokalizacja,
    w.kod_siatki,
    s.nazwa_poziomu,
    s.poziom_nr,
    w.kategoria_porownawcza,
    k.opis_kategorii,
    k.kolejnosc                                        as kategoria_kolejnosc,
    w.wynik_wartosciowania,
    p.punkty_laczne,
    p.punkty_warunki_pracy,
    -- roznica miedzy wynikiem ze zrodla a wynikiem przeliczonym z mostka
    round(w.wynik_wartosciowania - p.punkty_laczne, 3) as roznica_vs_przeliczenie
from w
left join punkty as p on w.stanowisko_id = p.stanowisko_id
left join siatka as s on w.kod_siatki = s.kod_siatki
left join dzialy as d on w.dzial_id = d.dzial_id
left join kategorie as k on w.kategoria_porownawcza = k.kategoria_porownawcza
