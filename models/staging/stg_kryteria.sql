select
    id_podkryterium::number         as podkryterium_id,
    kryterium_glowne::varchar       as kryterium_glowne,
    waga_kryterium::number(5, 3)    as waga_kryterium,
    podkryterium::varchar           as podkryterium,
    waga_podkryterium::number(6, 4) as waga_podkryterium,
    opis_1::varchar                 as opis_ocena_1,
    opis_5::varchar                 as opis_ocena_5
from {{ source('bakery_raw', 'D_KRYTERIA_WARTOSCIOWANIA') }}
