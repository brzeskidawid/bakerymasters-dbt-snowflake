{% snapshot snp_pracownicy %}

{{
    config(
        unique_key='pracownik_id',
        strategy='check',
        check_cols=['stanowisko_id', 'dzial_id', 'kod_siatki', 'wymiar_etatu', 'typ_umowy', 'data_zwolnienia'],
        hard_deletes='invalidate'
    )
}}

-- SCD typu 2 na slowniku pracownikow.
-- Zrodlo nadpisuje stan biezacy (nie ma historii stanowisk), wiec historie
-- buduje snapshot: kazda zmiana stanowiska, dzialu, poziomu siatki, wymiaru
-- etatu lub typu umowy zamyka poprzedni wiersz (dbt_valid_to) i otwiera nowy.

select * from {{ ref('stg_pracownicy') }}

{% endsnapshot %}
