SELECT c."название"                       AS "Название Компетенции",
       COUNT(DISTINCT z."ид_заявки")      AS "Количество Заявок",
       COUNT(DISTINCT sc."ид_сотрудника") AS "Количество Сотрудников",
       CASE WHEN COUNT(DISTINCT sc."ид_сотрудника") > 0
                THEN ROUND(COUNT(DISTINCT z."ид_заявки") * 1.0 / COUNT(DISTINCT sc."ид_сотрудника"), 2)
                ELSE 0
                END AS "Соотношение Заявок к Сотрудникам",
       CASE WHEN COUNT(DISTINCT sc."ид_сотрудника") > COUNT(DISTINCT z."ид_заявки")
                THEN 'Сотрудников хватает'
                ELSE 'Недобор сотрудников'
                END AS "Вердикт"
FROM "компетенции" c
LEFT JOIN
     "сотрудник_компетенции" sc ON c."ид_компетенции" = sc."ид_компетенции"
LEFT JOIN
     "заявки" z ON sc."ид_сотрудника" = z."ид_сотрудника"
GROUP BY c."ид_компетенции", c."название"
ORDER BY c."название";

