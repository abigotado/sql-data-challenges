WITH
    -- Создаём временную таблицу FILTERED_CARS для автомобилей,
    -- которые соответствуют условиям: мощность > 150 л.с., объем двигателя < 3 л, цена < 35 000$
    FILTERED_CARS AS (
        SELECT
            V.MAKER, -- Производитель автомобиля
            V.MODEL, -- Модель автомобиля
            C.HORSEPOWER, -- Мощность двигателя в лошадиных силах
            C.ENGINE_CAPACITY, -- Объем двигателя в литрах
            V.TYPE AS VEHICLE_TYPE -- Тип транспортного средства (Car)
        FROM
            VEHICLE V
                JOIN CAR C ON V.MODEL = C.MODEL
        WHERE
            C.HORSEPOWER > 150
          AND C.ENGINE_CAPACITY < 3
          AND C.PRICE < 35000
    ),
    -- Создаём временную таблицу FILTERED_MOTORCYCLES для мотоциклов,
    -- которые соответствуют условиям: мощность > 150 л.с., объем двигателя < 1.5 л, цена < 20 000$
    FILTERED_MOTORCYCLES AS (
        SELECT
            V.MAKER, -- Производитель мотоцикла
            V.MODEL, -- Модель мотоцикла
            M.HORSEPOWER, -- Мощность двигателя в лошадиных силах
            M.ENGINE_CAPACITY, -- Объем двигателя в литрах
            V.TYPE AS VEHICLE_TYPE -- Тип транспортного средства (Motorcycle)
        FROM
            VEHICLE V
                JOIN MOTORCYCLE M ON V.MODEL = M.MODEL
        WHERE
            M.HORSEPOWER > 150
          AND M.ENGINE_CAPACITY < 1.5
          AND M.PRICE < 20000
    ),
    -- Создаём временную таблицу FILTERED_BICYCLES для велосипедов,
    -- которые соответствуют условиям: количество передач > 18, цена < 4 000$
    -- Поля HORSEPOWER и ENGINE_CAPACITY у велосипедов отсутствуют, поэтому они заменены на NULL
    FILTERED_BICYCLES AS (
        SELECT
            V.MAKER, -- Производитель велосипеда
            V.MODEL, -- Модель велосипеда
            CAST(NULL AS INTEGER) AS HORSEPOWER, -- Для велосипедов мощность отсутствует (NULL)
            CAST(NULL AS DECIMAL(4,2)) AS ENGINE_CAPACITY, -- Для велосипедов объем двигателя отсутствует (NULL)
            V.TYPE AS VEHICLE_TYPE -- Тип транспортного средства (Bicycle)
        FROM
            VEHICLE V
                JOIN BICYCLE B ON V.MODEL = B.MODEL
        WHERE
            B.GEAR_COUNT > 18
          AND B.PRICE < 4000
    )
-- Объединяем данные из всех таблиц с помощью UNION ALL
-- и сортируем по убыванию мощности двигателя,
-- велосипеды с NULL значением HORSEPOWER будут в конце списка
SELECT
    *
FROM
    FILTERED_CARS
UNION ALL
SELECT
    *
FROM
    FILTERED_MOTORCYCLES
UNION ALL
SELECT
    *
FROM
    FILTERED_BICYCLES
ORDER BY
    HORSEPOWER DESC NULLS LAST;