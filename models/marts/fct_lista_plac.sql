{{
    config(
        materialized = 'incremental',
        unique_key = 'lista_plac_id',
        incremental_strategy = 'merge',
        on_schema_change = 'append_new_columns'
    )
}}

-- Tabela faktow: 1 wiersz = pracownik x miesiac.
-- Trzymamy wylacznie miary addytywne (kwoty, godziny, licznik).
-- Wszystko, co jest ilorazem (srednia, luka placowa, wynagrodzenie na etat
-- w skali grupy), liczy sie dopiero w modelu semantycznym - bo wynik zalezy
-- od tego, co uzytkownik zaznaczyl.

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
    to_number(to_char(data_miesiaca, 'YYYYMM')) as miesiac_key,
    rok_miesiac,
    data_miesiaca,
    rok,
    miesiac,
    wynagrodzenie_zasadnicze,
    premia,
    dodatki,
    wynagrodzenie_calkowite,
    wynagrodzenie_fte,
    wynagrodzenie_zasadnicze_fte,
    etat,
    godziny_nadliczbowe,
    staz_miesiace,
    1                                           as liczba_wyplat
from zrodlo
