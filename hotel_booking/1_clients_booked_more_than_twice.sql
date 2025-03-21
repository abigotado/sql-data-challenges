-- Определяем клиентов, которые сделали более двух бронирований в разных отелях

WITH CUSTOMER_BOOKINGS AS (
    -- Считаем количество бронирований и список уникальных отелей для каждого клиента
    SELECT
        B.ID_CUSTOMER, -- Уникальный идентификатор клиента
        C.NAME AS CUSTOMER_NAME, -- Имя клиента
        C.EMAIL AS CUSTOMER_EMAIL, -- Электронная почта клиента
        C.PHONE AS CUSTOMER_PHONE, -- Телефон клиента
        COUNT(B.ID_BOOKING) AS TOTAL_BOOKINGS, -- Общее количество бронирований
        STRING_AGG(DISTINCT H.NAME, ', ') AS BOOKED_HOTELS, -- Объединяем список уникальных отелей в строку через запятую
        AVG(B.CHECK_OUT_DATE - B.CHECK_IN_DATE) AS AVG_STAY_LENGTH -- Средняя длительность пребывания в днях
    FROM
        BOOKING B
        JOIN ROOM R ON B.ID_ROOM = R.ID_ROOM -- Присоединяем информацию о номере
        JOIN HOTEL H ON R.ID_HOTEL = H.ID_HOTEL -- Присоединяем информацию об отеле
        JOIN CUSTOMER C ON B.ID_CUSTOMER = C.ID_CUSTOMER -- Присоединяем информацию о клиенте
    GROUP BY
        B.ID_CUSTOMER, -- Группируем по уникальному идентификатору клиента
        C.NAME, -- Группируем по имени клиента
        C.EMAIL, -- Группируем по электронной почте клиента
        C.PHONE -- Группируем по телефону клиента
    HAVING
        COUNT(DISTINCT H.ID_HOTEL) > 1 -- Фильтруем клиентов, которые бронировали более одного отеля
)

-- Выбираем клиентов, сделавших более двух бронирований
SELECT
    CUSTOMER_NAME, -- Имя клиента
    CUSTOMER_EMAIL, -- Электронная почта клиента
    CUSTOMER_PHONE, -- Телефон клиента
    TOTAL_BOOKINGS, -- Общее количество бронирований
    BOOKED_HOTELS, -- Список отелей, в которых клиент делал бронирования
    AVG_STAY_LENGTH -- Средняя продолжительность проживания (в днях)
FROM
    CUSTOMER_BOOKINGS
WHERE
    TOTAL_BOOKINGS > 2 -- Фильтруем клиентов, сделавших более двух бронирований
ORDER BY
    TOTAL_BOOKINGS DESC; -- Сортируем по количеству бронирований в порядке убывания