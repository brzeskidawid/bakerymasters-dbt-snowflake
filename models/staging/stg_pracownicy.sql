with src as (
    select * from {{ source('bakery_raw', 'D_PRACOWNICY') }}
),

final as (
    select
        id_pracownika::number                             as pracownik_id,
        id_stanowiska::number                             as stanowisko_id,
        id_dzialu::number                                 as dzial_id,
        kod_siatki::varchar                               as kod_siatki,
        imie::varchar                                     as imie,
        nazwisko::varchar                                 as nazwisko,
        imie_nazwisko::varchar                            as pracownik,
        plec::varchar                                     as plec,
        data_urodzenia::date                              as data_urodzenia,
        data_zatrudnienia::date                           as data_zatrudnienia,
        try_to_date(nullif(data_zwolnienia::varchar, '')) as data_zwolnienia,
        wymiar_etatu::float                               as wymiar_etatu,
        typ_umowy::varchar                                as typ_umowy
    from src
)

select * from final
