-- Test pojedynczy: nie moze istniec wyplata za miesiac przed zatrudnieniem
-- ani po miesiacu zwolnienia. To regula biznesowa, nie techniczna -
-- dlatego test singular, a nie generic.

select
    f.lista_plac_id,
    f.pracownik_id,
    f.data_miesiaca,
    p.data_zatrudnienia,
    p.data_zwolnienia
from {{ ref('fct_lista_plac') }} as f
inner join {{ ref('dim_pracownik') }} as p
    on f.pracownik_id = p.pracownik_id
where
    f.data_miesiaca < date_trunc('month', p.data_zatrudnienia)
    or (
        p.data_zwolnienia is not null
        and f.data_miesiaca > date_trunc('month', p.data_zwolnienia)
    )
