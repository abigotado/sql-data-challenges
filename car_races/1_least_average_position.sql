-- Определяем автомобили с наименьшей средней позицией в гонках для каждого класса

WITH
    CAR_AVERAGE_POSITION AS (
        -- Вычисляем среднюю позицию для каждого автомобиля и количество его гонок
        SELECT
            C.NAME AS CAR_NAME, -- Название автомобиля
            C.CLASS AS CAR_CLASS, -- Класс автомобиля
            AVG(R.POSITION) AS AVERAGE_POSITION, -- Средняя позиция в гонках
            COUNT(R.RACE) AS RACE_COUNT -- Количество гонок, в которых участвовал автомобиль
        FROM
            CARS C
                JOIN RESULTS R ON C.NAME = R.CAR
        GROUP BY
            C.NAME,
            C.CLASS
    ),
    CAR_RANK AS (
        -- Присваиваем ранги автомобилям внутри каждого класса по средней позиции
        SELECT
            CAR_NAME,
            CAR_CLASS,
            AVERAGE_POSITION,
            RACE_COUNT,
            RANK() OVER (
                PARTITION BY
                    CAR_CLASS -- Группируем автомобили по классу
                ORDER BY
                    AVERAGE_POSITION -- Сортируем по средней позиции (от меньшей к большей)
                ) AS RANK
        FROM
            CAR_AVERAGE_POSITION
    )

-- Выбираем автомобили с наименьшей средней позицией в своем классе
SELECT
    CAR_NAME, -- Название автомобиля
    CAR_CLASS, -- Класс автомобиля
    AVERAGE_POSITION, -- Средняя позиция в гонках
    RACE_COUNT -- Количество гонок
FROM
    CAR_RANK
WHERE
    RANK = 1 -- Оставляем только автомобили с наименьшей средней позицией в своём классе
ORDER BY
    AVERAGE_POSITION; -- Сортируем по средней позиции (от лучшей к худшей)