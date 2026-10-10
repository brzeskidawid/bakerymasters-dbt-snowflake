{{ config(materialized='table') }}

-- Kalendarz w ziarnie DNIA, ciagly, od 1 stycznia roku pierwszej wyplaty
-- do 31 grudnia roku ostatniej. Pelne lata i brak dziur to warunek oznaczenia
-- tabeli jako tabeli dat w Power BI - bez tego nie dziala time intelligence.
-- Poprzednia wersja (ziarno miesiaca) tego warunku nie spelniala.

with granice as (
    select
        date_trunc('year', min(data_miesiaca))                   as data_od,
        last_day(date_trunc('year', max(data_miesiaca)), 'year') as data_do
    from {{ ref('stg_lista_plac') }}
),

spine as (
    select dateadd('day', seq4(), (select data_od from granice)) as data
    from table(generator(rowcount => 7300))
),

ograniczone as (
    select data
    from spine
    where data <= (select data_do from granice)
)

select
    data,
    to_number(to_char(data, 'YYYYMMDD'))      as data_key,
    year(data)                                as rok,
    quarter(data)                             as kwartal,
    'Q' || quarter(data)                      as kwartal_nazwa,
    'Q' || quarter(data) || ' ' || year(data) as kwartal_label,
    month(data)                               as miesiac,
    monthname(data)                           as miesiac_skrot,
    to_number(to_char(data, 'YYYYMM'))        as miesiac_key,
    to_char(data, 'YYYY-MM')                  as rok_miesiac,
    date_trunc('month', data)                 as pierwszy_dzien_miesiaca,
    last_day(data)                            as ostatni_dzien_miesiaca,
    weekofyear(data)                          as tydzien_roku,
    dayofweekiso(data)                        as dzien_tygodnia_nr,
    dayname(data)                             as dzien_tygodnia,
    iff(dayofweekiso(data) <= 5, true, false) as czy_dzien_roboczy
from ograniczone
