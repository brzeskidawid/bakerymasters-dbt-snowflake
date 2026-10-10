-- Test pojedynczy (singular): wynagrodzenie calkowite musi byc suma skladnikow.
-- Zapytanie ma zwrocic 0 wierszy. Kazdy zwrocony wiersz = blad.

select
    lista_plac_id,
    wynagrodzenie_zasadnicze,
    premia,
    dodatki,
    wynagrodzenie_calkowite,
    wynagrodzenie_calkowite - (wynagrodzenie_zasadnicze + premia + dodatki) as roznica
from {{ ref('fct_lista_plac') }}
where abs(wynagrodzenie_calkowite - (wynagrodzenie_zasadnicze + premia + dodatki)) > 0.01
