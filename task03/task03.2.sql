-- (1) Создаём специальную таблицу
CREATE TABLE spec
(
    id                              INTEGER PRIMARY KEY,
    "имя_таблицы"                   VARCHAR(255) NOT NULL,
    "имя_столбца"                   VARCHAR(255) NOT NULL DEFAULT 'id',
    "текущее_максимальное_значение" INTEGER
);


-- (2) Вставка значения в таблицу
INSERT INTO spec(id, имя_таблицы, имя_столбца, текущее_максимальное_значение)
VALUES (1, 'spec', 'id', 1);


-- (3) Создаём новую функцию
CREATE FUNCTION get_next_value(п_имя_таблицы VARCHAR(255), п_имя_столбца VARCHAR(255)) RETURNS INTEGER
AS
$$
DECLARE
    current_value INTEGER;
    max_value INTEGER;
BEGIN
    -- Получаем текущее значение по переданным параметрам
        current_value := текущее_максимальное_значение
                                   FROM spec
                                   WHERE spec.имя_таблицы = п_имя_таблицы
                                     AND имя_столбца = п_имя_столбца;

    -- Если оно равно null, то добавляем новую строку в спец. таблицу
    IF current_value IS NULL THEN
        EXECUTE format('SELECT COALESCE(MAX(%I), 0) FROM %I', п_имя_столбца, п_имя_таблицы) INTO max_value;

        INSERT INTO spec (id, имя_таблицы, имя_столбца, текущее_максимальное_значение)
        VALUES (get_next_value('spec', 'id'), п_имя_таблицы, п_имя_столбца, max_value + 1);

        RETURN max_value + 1;
    -- Иначе (если не равно null), инкрементируем значение в таблице и возвращаем исходное (до инкремента)
    ELSE
        UPDATE spec
        SET "текущее_максимальное_значение" = "текущее_максимальное_значение" + 1
        WHERE spec.имя_столбца = п_имя_столбца
          AND spec.имя_таблицы = п_имя_таблицы;
        RETURN current_value + 1;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- (4) Вызываем функцию
SELECT get_next_value('spec', 'id') AS "(4) Первый вызов";

-- (5) Распечатка содержимого спец. таблицы
SELECT * FROM spec;

-- (6) Вызываем функцию
SELECT get_next_value('spec', 'id') AS "(6) Второй вызов";

-- (7) Распечатка содержимого спец. таблицы
SELECT * FROM spec;

-- (8) Создание таблицы test
CREATE TABLE test
(
    id INTEGER PRIMARY KEY
);

--(9) Добавление записи в test
INSERT INTO test(id) VALUES (10);

-- (10) Вызываем функцию
SELECT get_next_value('test', 'id') AS "(10) Третий вызов";

-- (11) Распечатка содержимого спец. таблицы
SELECT * FROM spec;

-- (12) Вызываем функцию
SELECT get_next_value('test', 'id') AS "(12) Четвёртый вызов";

-- (13) Распечатка содержимого спец. таблицы
SELECT * FROM spec;

-- (14) Создание таблицы test2
CREATE TABLE test2
(
    num_value1 INTEGER,
    num_value2 INTEGER
);

-- (15) Вызываем функцию
SELECT get_next_value('test2', 'num_value1') AS "(15) Пятый вызов";

-- (16) Распечатка содержимого спец. таблицы
SELECT * FROM spec;

-- (17) Вызываем функцию
SELECT get_next_value('test2', 'num_value1') AS "(16) Шестой вызов";

-- (18) Распечатка содержимого спец. таблицы
SELECT * FROM spec;

-- (19) Добавление значения
INSERT INTO test2(num_value1, num_value2) VALUES (2, 13);

-- (20) Вызываем функцию
SELECT get_next_value('test2', 'num_value2') AS "(20) Седьмой вызов";

-- (21) Распечатка содержимого спец. таблицы
SELECT * FROM spec;

-- (22) Вызываем функцию 5 раз
SELECT get_next_value('test2', 'num_value1');
SELECT get_next_value('test2', 'num_value1');
SELECT get_next_value('test2', 'num_value1');
SELECT get_next_value('test2', 'num_value1');
SELECT get_next_value('test2', 'num_value1');

-- (23) Распечатка содержимого спец. таблицы
SELECT * FROM spec;

-- (24) Удаление функции
DROP FUNCTION IF EXISTS get_next_value(п_имя_таблицы VARCHAR, п_имя_столбца VARCHAR);

-- (25) Удаление таблиц
DROP TABLE IF EXISTS spec;
DROP TABLE IF EXISTS test;
DROP TABLE IF EXISTS test2;
