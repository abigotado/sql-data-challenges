WITH
    CUSTOMER_BOOKINGS AS (
        -- Определяем клиентов, которые сделали более двух бронирований в разных отелях
        SELECT
            B.ID_CUSTOMER, -- Уникальный идентификатор клиента
            C.NAME AS NAME, -- Имя клиента
            COUNT(B.ID_BOOKING) AS TOTAL_BOOKINGS, -- Общее количество бронирований клиента
            COUNT(DISTINCT H.ID_HOTEL) AS UNIQUE_HOTELS, -- Количество уникальных отелей, в которых клиент делал бронирования
            SUM(R.PRICE * (B.CHECK_OUT_DATE - B.CHECK_IN_DATE)) AS TOTAL_SPENT -- Общая сумма, потраченная клиентом на бронирования
        FROM
            BOOKING B
                JOIN ROOM R ON B.ID_ROOM = R.ID_ROOM -- Присоединяем информацию о номере
                JOIN HOTEL H ON R.ID_HOTEL = H.ID_HOTEL -- Присоединяем информацию об отеле
                JOIN CUSTOMER C ON B.ID_CUSTOMER = C.ID_CUSTOMER -- Присоединяем информацию о клиенте
        GROUP BY
            B.ID_CUSTOMER,
            C.NAME
        HAVING
            COUNT(B.ID_BOOKING) > 2 -- Оставляем только клиентов, которые сделали более двух бронирований
           AND COUNT(DISTINCT H.ID_HOTEL) > 1 -- Оставляем только клиентов, забронировавших номера в более чем одном отеле
    )

-- Выбираем клиентов, которые соответствуют обоим условиям: бронирования > 2 и сумма > 500 долларов
SELECT
    CB.ID_CUSTOMER, -- Уникальный идентификатор клиента
    CB.NAME, -- Имя клиента
    CB.TOTAL_BOOKINGS, -- Общее количество бронирований клиента
    CB.TOTAL_SPENT, -- Общая сумма, потраченная клиентом на бронирования
    CB.UNIQUE_HOTELS -- Количество уникальных отелей, в которых клиент делал бронирования
FROM
    CUSTOMER_BOOKINGS CB
WHERE
    CB.TOTAL_SPENT > 500 -- Оставляем клиентов, потративших более 500 долларов
ORDER BY
    CB.TOTAL_SPENT; -- Сортируем по общей сумме, потраченной клиентами, в порядке возрастания