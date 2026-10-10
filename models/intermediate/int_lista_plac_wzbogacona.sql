{{ config(materialized='ephemeral') }}

-- Laczy liste plac z atrybutami pracownika potrzebnymi do wyliczen addytywnych
-- (przeliczenie na pelny etat, staz w miesiacach). Wszystko, co tu powstaje,
-- jest niezalezne od tego, co uzytkownik klika w raporcie.

with place as (
    select * from {{ ref('stg_lista_plac') }}
),

pracownicy as (
    select * from {{ ref('stg_pracownicy') }}
)

select
    pl.lista_plac_id,
    pl.pracownik_id,
    p.stanowisko_id,
    p.dzial_id,
    p.kod_siatki,
    pl.rok_miesiac,
    pl.data_miesiaca,
    pl.rok,
    pl.miesiac,
    pl.wynagrodzenie_zasadnicze,
    pl.premia,
    pl.dodatki,
    pl.wynagrodzenie_calkowite,
    pl.etat,
    pl.godziny_nadliczbowe,
    -- wynagrodzenie sprowadzone do pelnego etatu: porownywalne miedzy pracownikami
    {{ na_pelny_etat('pl.wynagrodzenie_calkowite', 'pl.etat') }}  as wynagrodzenie_fte,
    {{ na_pelny_etat('pl.wynagrodzenie_zasadnicze', 'pl.etat') }} as wynagrodzenie_zasadnicze_fte,
    datediff('month', p.data_zatrudnienia, pl.data_miesiaca)      as staz_miesiace
from place as pl
inner join pracownicy as p
    on pl.pracownik_id = p.pracownik_id
