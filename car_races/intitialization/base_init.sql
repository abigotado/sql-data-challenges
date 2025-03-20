-- Создание таблицы Classes
CREATE TABLE CLASSES (
                         CLASS VARCHAR(100) NOT NULL,
                         TYPE VARCHAR(20) NOT NULL CHECK (TYPE IN ('Racing', 'Street')), -- тип класса
                         COUNTRY VARCHAR(100) NOT NULL,
                         NUMDOORS INT NOT NULL,
                         ENGINESIZE DECIMAL(3, 1) NOT NULL, -- размер двигателя в литрах
                         WEIGHT INT NOT NULL, -- вес автомобиля в килограммах
                         PRIMARY KEY (CLASS)
);

-- Создание таблицы Cars
CREATE TABLE CARS (
                      NAME VARCHAR(100) NOT NULL,
                      CLASS VARCHAR(100) NOT NULL,
                      YEAR INT NOT NULL,
                      PRIMARY KEY (NAME),
                      FOREIGN KEY (CLASS) REFERENCES CLASSES (CLASS)
);

-- Создание таблицы Races
CREATE TABLE RACES (
                       NAME VARCHAR(100) NOT NULL,
                       DATE DATE NOT NULL,
                       PRIMARY KEY (NAME)
);

-- Создание таблицы Results
CREATE TABLE RESULTS (
                         CAR VARCHAR(100) NOT NULL,
                         RACE VARCHAR(100) NOT NULL,
                         POSITION INT NOT NULL,
                         PRIMARY KEY (CAR, RACE),
                         FOREIGN KEY (CAR) REFERENCES CARS (NAME),
                         FOREIGN KEY (RACE) REFERENCES RACES (NAME)
);

-- Вставка данных в таблицу Classes
INSERT INTO
    CLASSES (
    CLASS,
    TYPE,
    COUNTRY,
    NUMDOORS,
    ENGINESIZE,
    WEIGHT
)
VALUES
    ('SportsCar', 'Racing', 'USA', 2, 3.5, 1500),
    ('Sedan', 'Street', 'Germany', 4, 2.0, 1200),
    ('SUV', 'Street', 'Japan', 4, 2.5, 1800),
    ('Hatchback', 'Street', 'France', 5, 1.6, 1100),
    ('Convertible', 'Racing', 'Italy', 2, 3.0, 1300),
    ('Coupe', 'Street', 'USA', 2, 2.5, 1400),
    ('Luxury Sedan', 'Street', 'Germany', 4, 3.0, 1600),
    ('Pickup', 'Street', 'USA', 2, 2.8, 2000);

-- Вставка данных в таблицу Cars
INSERT INTO
    CARS (NAME, CLASS, YEAR)
VALUES
    ('Ford Mustang', 'SportsCar', 2020),
    ('BMW 3 Series', 'Sedan', 2019),
    ('Toyota RAV4', 'SUV', 2021),
    ('Renault Clio', 'Hatchback', 2020),
    ('Ferrari 488', 'Convertible', 2019),
    ('Chevrolet Camaro', 'Coupe', 2021),
    ('Mercedes-Benz S-Class', 'Luxury Sedan', 2022),
    ('Ford F-150', 'Pickup', 2021),
    ('Audi A4', 'Sedan', 2018),
    ('Nissan Rogue', 'SUV', 2020);

-- Вставка данных в таблицу Races
INSERT INTO
    RACES (NAME, DATE)
VALUES
    ('Indy 500', '2023-05-28'),
    ('Le Mans', '2023-06-10'),
    ('Monaco Grand Prix', '2023-05-28'),
    ('Daytona 500', '2023-02-19'),
    ('Spa 24 Hours', '2023-07-29'),
    ('Bathurst 1000', '2023-10-08'),
    ('Nürburgring 24 Hours', '2023-06-17'),
    (
        'Pikes Peak International Hill Climb',
        '2023-06-25'
    );

-- Вставка данных в таблицу Results
INSERT INTO
    RESULTS (CAR, RACE, POSITION)
VALUES
    ('Ford Mustang', 'Indy 500', 1),
    ('BMW 3 Series', 'Le Mans', 3),
    ('Toyota RAV4', 'Monaco Grand Prix', 2),
    ('Renault Clio', 'Daytona 500', 5),
    ('Ferrari 488', 'Le Mans', 1),
    ('Chevrolet Camaro', 'Monaco Grand Prix', 4),
    ('Mercedes-Benz S-Class', 'Spa 24 Hours', 2),
    ('Ford F-150', 'Bathurst 1000', 6),
    ('Audi A4', 'Nürburgring 24 Hours', 8),
    (
        'Nissan Rogue',
        'Pikes Peak International Hill Climb',
        3
    );