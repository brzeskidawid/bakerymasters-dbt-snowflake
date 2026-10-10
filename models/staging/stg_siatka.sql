select
    kod_siatki::varchar    as kod_siatki,
    nazwa_poziomu::varchar as nazwa_poziomu,
    poziom_nr::number      as poziom_nr
from {{ source('bakery_raw', 'D_SIATKA') }}
