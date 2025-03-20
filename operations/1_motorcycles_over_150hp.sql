-- Определяем временную таблицу (Common Table Expression - CTE)
-- SPORT_MOTORCYCLES содержит только спортивные мотоциклы с мощностью > 150 л.с. и ценой < 20000$
WITH SPORT_MOTORCYCLES AS (
    SELECT
        V.MAKER,  -- Производитель мотоцикла
        V.MODEL,  -- Модель мотоцикла
        M.HORSEPOWER -- Мощность двигателя в л.с.
    FROM
        VEHICLE V
        JOIN MOTORCYCLE M ON V.MODEL = M.MODEL  -- Соединяем таблицы VEHICLE и MOTORCYCLE по модели
    WHERE
        M.HORSEPOWER > 150  -- Фильтр по мощности двигателя
        AND M.PRICE < 20000  -- Фильтр по цене
        AND M.TYPE = 'Sport' -- Выбираем только спортивные мотоциклы
)

-- Финальный запрос, выбирающий производителей и модели из CTE
SELECT
    MAKER,  -- Производитель мотоцикла
    MODEL   -- Модель мотоцикла
FROM
    SPORT_MOTORCYCLES
ORDER BY
    HORSEPOWER DESC; -- Сортируем по мощности двигателя (от большего к меньшему)