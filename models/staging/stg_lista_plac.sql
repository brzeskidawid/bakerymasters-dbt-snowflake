with src as (
    select * from {{ source('bakery_raw', 'F_LISTA_PLAC') }}
),

final as (
    select
        id_listy::number                                     as lista_plac_id,
        id_pracownika::number                                as pracownik_id,
        rok_miesiac::varchar                                 as rok_miesiac,
        to_date(rok_miesiac::varchar || '-01', 'YYYY-MM-DD') as data_miesiaca,
        rok::number                                          as rok,
        miesiac::number                                      as miesiac,
        wynagrodzenie_zasadnicze::number(12, 2)              as wynagrodzenie_zasadnicze,
        premia::number(12, 2)                                as premia,
        dodatki::number(12, 2)                               as dodatki,
        wynagrodzenie_calkowite::number(12, 2)               as wynagrodzenie_calkowite,
        etat::float                                          as etat,
        godziny_nadliczbowe::number                          as godziny_nadliczbowe
    from src
)

select * from final
