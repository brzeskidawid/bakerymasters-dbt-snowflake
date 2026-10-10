select
    id_stanowiska::number               as stanowisko_id,
    stanowisko::varchar                 as stanowisko,
    id_dzialu::number                   as dzial_id,
    kod_siatki::varchar                 as kod_siatki,
    kategoria_porownawcza::varchar      as kategoria_porownawcza,
    wynik_wartosciowania::number(10, 3) as wynik_wartosciowania
from {{ source('bakery_raw', 'D_WARTOSCIOWANIE') }}
