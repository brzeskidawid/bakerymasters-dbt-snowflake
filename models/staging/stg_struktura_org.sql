select
    id_dzialu::number    as dzial_id,
    dzial::varchar       as dzial,
    pion::varchar        as pion,
    lokalizacja::varchar as lokalizacja
from {{ source('bakery_raw', 'D_STRUKTURA_ORG') }}
