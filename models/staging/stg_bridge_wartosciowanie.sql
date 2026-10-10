select
    id_stanowiska::number as stanowisko_id,
    stanowisko::varchar   as stanowisko,
    podkryterium::varchar as podkryterium,
    ocena::number         as ocena
from {{ source('bakery_raw', 'BRIDGE_WARTOSCIOWANIE') }}
