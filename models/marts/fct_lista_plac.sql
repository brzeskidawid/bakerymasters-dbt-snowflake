{{
    config(
        materialized = 'incremental',
        unique_key = 'lista_plac_id',
        incremental_strategy = 'merge',
        on_schema_change = 'sync_all_columns'
    )
}}

-- Tabela faktow: 1 wiersz = pracownik x miesiac.
-- Trzymamy wylacznie klucze obce i miary addytywne. Atrybuty czasu (rok,
-- kwartal, nazwa miesiaca) nie powtarzaja sie w fakcie - sa w D_Calendar.
-- Wszystko, co jest ilorazem, liczy sie w modelu semantycznym.

with zrodlo as (
    select * from {{ ref('int_lista_plac_wzbogacona') }}

    {% if is_incremental() %}
    -- przy kolejnych uruchomieniach przetwarzamy tylko nowe miesiace
        where data_miesiaca > (select coalesce(max(data_miesiaca), '1900-01-01') from {{ this }})
    {% endif %}
)

select
    lista_plac_id,
    pracownik_id,
    stanowisko_id,
    dzial_id,
    kod_siatki,
    data_miesiaca,
    wynagrodzenie_zasadnicze,
    premia,
    dodatki,
    wynagrodzenie_calkowite,
    wynagrodzenie_fte,
    wynagrodzenie_zasadnicze_fte,
    etat,
    godziny_nadliczbowe,
    staz_miesiace,
    1 as liczba_wyplat
from zrodlo
