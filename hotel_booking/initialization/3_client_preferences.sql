-- Определяем категорию каждого отеля на основе средней стоимости номера
WITH
    HOTEL_CATEGORIES AS (
        SELECT
            H.ID_HOTEL, -- Уникальный идентификатор отеля
            H.NAME AS HOTEL_NAME, -- Название отеля
            CASE
                WHEN AVG(R.PRICE) < 175 THEN 'Дешевый' -- Если средняя стоимость номера менее 175 долларов
                WHEN AVG(R.PRICE) BETWEEN 175 AND 300  THEN 'Средний' -- Если стоимость от 175 до 300 долларов
                ELSE 'Дорогой' -- Если стоимость номера превышает 300 долларов
                END AS HOTEL_CATEGORY
        FROM
            HOTEL H
                JOIN ROOM R ON H.ID_HOTEL = R.ID_HOTEL -- Присоединяем информацию о номерах отеля
        GROUP BY
            H.ID_HOTEL,
            H.NAME
    ),
    CLIENT_HOTEL_PREFERENCES AS (
        -- Определяем предпочитаемый тип отеля для каждого клиента
        SELECT
            B.ID_CUSTOMER, -- Уникальный идентификатор клиента
            C.NAME AS CLIENT_NAME, -- Имя клиента
            STRING_AGG(DISTINCT HC.HOTEL_NAME, ', ') AS VISITED_HOTELS, -- Список уникальных отелей, в которых клиент бронировал номера
            CASE
                -- Если у клиента есть хотя бы один дорогой отель, назначаем ему категорию "Дорогой"
                WHEN COUNT(
                             DISTINCT CASE
                                          WHEN HC.HOTEL_CATEGORY = 'Дорогой' THEN H.ID_HOTEL
                            END
                     ) > 0 THEN 'Дорогой'
                -- Если у клиента нет дорогих отелей, но есть хотя бы один средний, назначаем "Средний"
                WHEN COUNT(
                             DISTINCT CASE
                                          WHEN HC.HOTEL_CATEGORY = 'Средний' THEN H.ID_HOTEL
                            END
                     ) > 0 THEN 'Средний'
                -- В противном случае назначаем категорию "Дешевый"
                ELSE 'Дешевый'
                END AS PREFERRED_HOTEL_TYPE
        FROM
            BOOKING B
                JOIN ROOM R ON B.ID_ROOM = R.ID_ROOM -- Присоединяем информацию о номерах
                JOIN HOTEL H ON R.ID_HOTEL = H.ID_HOTEL -- Присоединяем информацию об отелях
                JOIN HOTEL_CATEGORIES HC ON H.ID_HOTEL = HC.ID_HOTEL -- Присоединяем категории отелей
                JOIN CUSTOMER C ON B.ID_CUSTOMER = C.ID_CUSTOMER -- Присоединяем информацию о клиентах
        GROUP BY
            B.ID_CUSTOMER,
            C.NAME
    )
-- Выбираем предпочтения клиентов и сортируем по категориям
SELECT
    ID_CUSTOMER AS ID_CUSTOMER, -- Уникальный идентификатор клиента
    CLIENT_NAME AS NAME, -- Имя клиента
    PREFERRED_HOTEL_TYPE, -- Предпочитаемая категория отелей
    VISITED_HOTELS -- Список уникальных отелей, в которых клиент останавливался
FROM
    CLIENT_HOTEL_PREFERENCES
ORDER BY
    CASE PREFERRED_HOTEL_TYPE
        WHEN 'Дешевый' THEN 1 -- Сначала клиенты, предпочитающие дешевые отели
        WHEN 'Средний' THEN 2 -- Затем клиенты со средними отелями
        WHEN 'Дорогой' THEN 3 -- В конце клиенты, которые останавливались в дорогих отелях
        END;