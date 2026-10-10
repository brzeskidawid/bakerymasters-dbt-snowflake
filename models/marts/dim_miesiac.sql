{{ config(materialized='table') }}

-- Wymiar czasu na poziomie miesiaca, zbudowany z zakresu wystepujacego na liscie plac.

with granice as (
    select
        min(data_miesiaca) as data_od,
        max(data_miesiaca) as data_do
    from {{ ref('stg_lista_plac') }}
),

spine as (
    select dateadd('month', seq4(), (select data_od from granice)) as data_miesiaca
    from table(generator(rowcount => 240))
),

ograniczone as (
    select data_miesiaca
    from spine
    where data_miesiaca <= (select data_do from granice)
)

select
    to_number(to_char(data_miesiaca, 'YYYYMM'))                 as miesiac_key,
    data_miesiaca,
    to_char(data_miesiaca, 'YYYY-MM')                           as rok_miesiac,
    year(data_miesiaca)                                         as rok,
    month(data_miesiaca)                                        as miesiac,
    quarter(data_miesiaca)                                      as kwartal,
    'Q' || quarter(data_miesiaca) || ' ' || year(data_miesiaca) as kwartal_label,
    last_day(data_miesiaca)                                     as koniec_miesiaca
from ograniczone
