select
    kategoria_porownawcza::varchar as kategoria_porownawcza,
    opis_kategorii::varchar        as opis_kategorii,
    kolejnosc::number              as kolejnosc
from {{ source('bakery_raw', 'D_KATEGORIE_POROWNAWCZE') }}
