WITH
    CAR_RESULTS AS (
        -- Вычисляем среднюю позицию для каждого автомобиля, количество его гонок и страну производства класса автомобиля
        SELECT
            C.NAME AS CAR_NAME, -- Название автомобиля
            C.CLASS AS CAR_CLASS, -- Класс автомобиля
            AVG(R.POSITION) AS AVERAGE_POSITION, -- Средняя позиция автомобиля в гонках
            COUNT(R.RACE) AS RACE_COUNT, -- Количество гонок, в которых участвовал автомобиль
            CL.COUNTRY AS CAR_COUNTRY -- Страна производства класса автомобиля
        FROM
            RESULTS R
                JOIN CARS C ON R.CAR = C.NAME -- Присоединяем автомобили к результатам гонок
                JOIN CLASSES CL ON CL.CLASS = C.CLASS -- Присоединяем информацию о классе автомобиля
        GROUP BY
            C.NAME,
            C.CLASS,
            CL.COUNTRY
        HAVING
            AVG(R.POSITION) > 3.0 -- Оставляем только автомобили, средняя позиция которых выше 3.0
    ),

    CLASS_RESULTS AS (
        -- Вычисляем количество автомобилей с низкой средней позицией в каждом классе и общее число гонок для класса
        SELECT
            C.CLASS AS CLASS, -- Класс автомобиля
            COUNT(C.NAME) AS CAR_COUNT, -- Количество автомобилей в классе с низкой средней позицией
            COUNT(R.RACE) AS TOTAL_RACES -- Общее количество гонок, в которых участвовали автомобили класса
        FROM
            RESULTS R
                JOIN CARS C ON R.CAR = C.NAME -- Присоединяем автомобили к результатам гонок
        GROUP BY
            C.CLASS
    )

-- Выбираем автомобили из классов с наибольшим числом автомобилей с низкой средней позицией
SELECT
    CR.CAR_NAME AS CAR_NAME, -- Название автомобиля
    CR.CAR_CLASS AS CAR_CLASS, -- Класс автомобиля
    CR.AVERAGE_POSITION AS AVERAGE_POSITION, -- Средняя позиция автомобиля в гонках
    CR.RACE_COUNT AS RACE_COUNT, -- Количество гонок, в которых участвовал автомобиль
    CR.CAR_COUNTRY AS CAR_COUNTRY, -- Страна производства автомобиля
    CLS.TOTAL_RACES AS TOTAL_RACES, -- Общее количество гонок для данного класса
    CLS.CAR_COUNT AS LOW_POSITION_COUNT -- Количество автомобилей с низкой средней позицией в классе
FROM
    CAR_RESULTS CR
        JOIN CLASS_RESULTS CLS ON CLS.CLASS = CR.CAR_CLASS -- Присоединяем данные о классах автомобилей
ORDER BY
    LOW_POSITION_COUNT DESC; -- Сортируем по количеству автомобилей с низкой средней позицией (по убыванию)