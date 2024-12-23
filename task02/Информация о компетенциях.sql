SELECT c."название"              AS "Название",
       COUNT(sc."ид_сотрудника") AS "Количество компетентных сотрудников"
FROM "компетенции" c
         LEFT JOIN
     "сотрудник_компетенции" sc ON c."ид_компетенции" = sc."ид_компетенции"
GROUP BY c."ид_компетенции", c."название"
ORDER BY c."название";