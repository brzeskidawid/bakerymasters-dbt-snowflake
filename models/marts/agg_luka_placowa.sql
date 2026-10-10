{{ config(materialized='table') }}

-- Skladniki do liczenia luki placowej, w ziarnie miesiac x stanowisko x plec.
-- Celowo NIE liczymy tu samej luki w procentach: to iloraz, ktory zalezy od
-- wybranego przekroju. Dostarczamy sumy i licznosci - reszte robi DAX.

with f as (
    select * from {{ ref('fct_lista_plac') }}
),

p as (
    select
        pracownik_id,
        plec
    from {{ ref('dim_pracownik') }}
)

select
    f.miesiac_key,
    f.rok_miesiac,
    f.rok,
    f.stanowisko_id,
    p.plec,
    count(distinct f.pracownik_id) as liczba_pracownikow,
    sum(f.wynagrodzenie_fte)       as suma_wynagrodzen_fte,
    sum(f.wynagrodzenie_calkowite) as suma_wynagrodzen,
    sum(f.wynagrodzenie_zasadnicze) as suma_wynagrodzen_zasadniczych, -- dodane
    sum(f.etat)                    as suma_etatow,
    sum(f.godziny_nadliczbowe)     as suma_nadgodzin
from f
inner join p on f.pracownik_id = p.pracownik_id
group by 1, 2, 3, 4, 5
