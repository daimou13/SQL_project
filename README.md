# Projekt 4 – SQL

## Popis projektu

Projekt analyzuje vývoj mezd a cen základních potravin v České republice a jejich vztah k makroekonomickým ukazatelům. Cílem je připravit datový podklad pro zodpovězení pěti výzkumných otázek zaměřených na dostupnost potravin, vývoj mezd, růst cen a vztah těchto ukazatelů k HDP.

Analýza pracuje s daty za období **2006–2018**.

## Použité datové zdroje

Pro vytvoření výsledných tabulek byly použity zejména tyto tabulky:

- `czechia_payroll`
- `czechia_payroll_industry_branch`
- `czechia_price`
- `czechia_price_category`
- `countries`
- `economies`

Z původních dat byly vytvořeny dvě výsledné tabulky:

- `t_dmytro_syrvatka_project_SQL_primary_final` – mzdy podle odvětví a ceny potravin v ČR
- `t_dmytro_syrvatka_project_SQL_secondary_final` – HDP, GINI koeficient a populace evropských států

## Použité nástroje

- PostgreSQL
- DBeaver
- SQL
- Git / GitHub

## Použité SQL techniky

V projektu byly použity mimo jiné:

- `JOIN`
- `GROUP BY`
- agregační funkce `AVG()`, `MIN()`, `MAX()`, `COUNT()`
- CTE (`WITH`)
- window funkce `LAG()` a `LEAD()`
- `CASE`
- práce s `NULL`
- výpočet meziročních procentuálních změn
- převod datových typů pomocí `::numeric`

---

# Výzkumné otázky

## 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Mzdy nerostly ve všech odvětvích každý rok.

Z 19 sledovaných odvětví došlo alespoň k jednomu meziročnímu poklesu mzdy v **15 odvětvích**. Celkem bylo zaznamenáno **24 případů meziročního poklesu**.

Nejčastější pokles byl zaznamenán v těchto odvětvích:

- **Těžba a dobývání** – pokles ve 4 letech
- **Výroba a rozvod elektřiny, plynu, tepla a klimatizovaného vzduchu** – pokles ve 3 letech
- několik dalších odvětví zaznamenalo pokles ve 2 letech

Pouze čtyři odvětví neměla v období 2006–2018 ani jeden meziroční pokles:

- **Zpracovatelský průmysl**
- **Doprava a skladování**
- **Zdravotní a sociální péče**
- **Ostatní činnosti**

Závěr: dlouhodobý trend mezd je převážně rostoucí, ale meziroční pokles se ve většině odvětví alespoň jednou objevil.

## 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?

Pro porovnání byly použity roky **2006 a 2018**.

### Rok 2006

Průměrná mzda: **21 165,18 Kč**

- chléb: **16,12 Kč / kg**
- mléko: **14,44 Kč / l**

Za průměrnou mzdu bylo možné koupit přibližně:

- **1 312,98 kg chleba**
- **1 465,73 l mléka**

### Rok 2018

Průměrná mzda: **33 091,45 Kč**

- chléb: **24,24 Kč / kg**
- mléko: **19,82 Kč / l**

Za průměrnou mzdu bylo možné koupit přibližně:

- **1 365,16 kg chleba**
- **1 669,60 l mléka**

Závěr: kupní síla se mezi roky 2006 a 2018 u obou sledovaných potravin zvýšila. U chleba přibližně o **3,97 %**, u mléka přibližně o **13,91 %**.

## 3. Která kategorie potravin zdražuje nejpomaleji?

Nejnižší průměrnou meziroční změnu ceny měl **cukr krystalový**.

- kód kategorie: `118101`
- průměrná meziroční změna: **−1,92 %**
- počet meziročních porovnání: **12**

Záporná hodnota znamená, že cena cukru ve sledovaném období v průměru meziročně mírně klesala.

Druhou nejnižší hodnotu měla **rajská jablka červená kulatá** s průměrnou meziroční změnou **−0,74 %**.

## 4. Existuje rok, kdy byl meziroční nárůst cen potravin výrazně vyšší než růst mezd?

Za výrazně vyšší byl považován rozdíl větší než **10 procentních bodů**.

Ve sledovaném období se takový rok nevyskytl.

Největší rozdíl nastal v roce **2013**:

- růst mezd: **−1,56 %**
- růst cen potravin: **+5,10 %**
- rozdíl: **6,65 procentního bodu**

Závěr: v žádném sledovaném roce nepřevýšil růst cen potravin růst mezd o více než 10 procentních bodů.

## 5. Má výše HDP vliv na změny ve mzdách a cenách potravin?

Byl porovnán meziroční růst HDP České republiky s meziročním růstem mezd a cen potravin ve stejném a následujícím roce.

Příklady:

- **2007:** HDP +5,57 %, mzdy +6,88 %, ceny potravin +6,76 %
- **2017:** HDP +5,17 %, mzdy +6,17 %, ceny potravin +9,63 %
- **2015:** HDP +5,39 %, mzdy +2,60 %, ceny potravin −0,55 %

Výsledky neukazují jednoznačný vztah, kdy by výraznější růst HDP automaticky vedl k výraznějšímu růstu mezd nebo cen potravin ve stejném či následujícím roce.

Závěr: na základě dostupných dat nelze potvrdit jednoduchou přímou závislost mezi růstem HDP a růstem mezd nebo cen potravin. Výsledky také samy o sobě neprokazují kauzální vztah.

---

# Struktura projektu

Repozitář obsahuje:

- `project_4_sql_clean.sql` – SQL skript pro vytvoření výsledných tabulek a zodpovězení výzkumných otázek
- `README.md` – popis projektu, použitých dat a hlavních výsledků

## Spuštění projektu

1. Připojte se k databázi v PostgreSQL.
2. Otevřete soubor `project_4_sql_clean.sql` například v DBeaveru.
3. Spusťte celý SQL skript.
4. Skript vytvoří výsledné tabulky a následně provede jednotlivé analytické dotazy.

## Autor

**Dmytro Syrvatka**
