{#
    Sprowadza kwote do pelnego etatu. Uzywane w int_lista_plac_wzbogacona.
    Makro, a nie powtorzony kawalek SQL-a, bo regula "dziel przez etat,
    chron sie przed dzieleniem przez zero, zaokraglij do groszy" ma byc
    w projekcie zdefiniowana raz.
#}
{% macro na_pelny_etat(kwota, etat) %}
    round({{ kwota }} / nullif({{ etat }}, 0), 2)
{% endmacro %}
