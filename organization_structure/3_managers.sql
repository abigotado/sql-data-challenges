-- Рекурсивно находим всех сотрудников, которые являются менеджерами и их подчиненных
WITH RECURSIVE EmployeeHierarchy AS (
    -- Базовый уровень: выбираем всех менеджеров
    -- Здесь мы выбираем уникальных менеджеров, используя JOIN для получения информации о их отделах и ролях.
    SELECT DISTINCT
        E.EmployeeID,
        E.Name AS EmployeeName,
        E.ManagerID,
        D.DepartmentName,
        R.RoleName
    FROM Employees E
    JOIN Departments D ON E.DepartmentID = D.DepartmentID -- Соединяем таблицу сотрудников с таблицей отделов по идентификатору отдела
    JOIN Roles R ON E.RoleID = R.RoleID -- Соединяем таблицу сотрудников с таблицей ролей по идентификатору роли
    WHERE R.RoleName = 'Менеджер' -- Фильтруем только тех, кто имеет роль менеджера

    UNION ALL

    -- Рекурсивный шаг: включаем всех подчинённых (включая подчинённых подчинённых)
    -- Здесь мы рекурсивно выбираем всех сотрудников, которые подчиняются менеджерам, ранее выбранным в базовом уровне.
    SELECT DISTINCT
        E.EmployeeID,
        E.Name,
        E.ManagerID,
        D.DepartmentName,
        R.RoleName
    FROM Employees E
    JOIN EmployeeHierarchy EH ON E.ManagerID = EH.EmployeeID -- Соединяем сотрудников с их менеджерами из предыдущего уровня
    JOIN Departments D ON E.DepartmentID = D.DepartmentID -- Получаем информацию об отделе для каждого подчиненного
    JOIN Roles R ON E.RoleID = R.RoleID -- Получаем информацию о роли для каждого подчиненного
),

-- Определяем список проектов для каждого менеджера
ManagerProjects AS (
    -- Здесь мы собираем все проекты, связанные с менеджерами, используя агрегатную функцию STRING_AGG для объединения названий проектов в одну строку.
    SELECT
        E.EmployeeID,
        STRING_AGG(DISTINCT P.ProjectName, ', ') AS ProjectNames -- Объединяем уникальные названия проектов в строку
    FROM Projects P
    JOIN Employees E ON E.DepartmentID = P.DepartmentID -- Соединяем проекты с сотрудниками по идентификатору отдела
    WHERE E.EmployeeID IN (SELECT EmployeeID FROM EmployeeHierarchy) -- Фильтруем только тех сотрудников, которые являются менеджерами или подчиненными
    GROUP BY E.EmployeeID -- Группируем результаты по идентификатору сотрудника
),

-- Определяем список задач для каждого менеджера
ManagerTasks AS (
    -- Здесь мы собираем все задачи, назначенные менеджерам, аналогично предыдущему блоку, используя агрегатную функцию STRING_AGG.
    SELECT
        T.AssignedTo AS EmployeeID,
        STRING_AGG(DISTINCT T.TaskName, ', ') AS TaskNames -- Объединяем уникальные названия задач в строку
    FROM Tasks T
    WHERE T.AssignedTo IN (SELECT EmployeeID FROM EmployeeHierarchy) -- Фильтруем только тех сотрудников, которые являются менеджерами или подчиненными
    GROUP BY T.AssignedTo -- Группируем результаты по идентификатору сотрудника
),

-- Подсчитываем **всех** подчинённых у каждого менеджера (включая их подчинённых)
ManagerSubordinates AS (
    -- Здесь мы подсчитываем общее количество уникальных подчиненных для каждого менеджера.
    SELECT
        EH.ManagerID,
        COUNT(DISTINCT EH.EmployeeID) AS TotalSubordinates -- Подсчитываем уникальных подчиненных для каждого менеджера
    FROM EmployeeHierarchy EH
    GROUP BY EH.ManagerID -- Группируем результаты по идентификатору менеджера
)

-- Итоговый запрос
SELECT DISTINCT
    EH.EmployeeID,
    EH.EmployeeName,
    EH.ManagerID,
    EH.DepartmentName,
    EH.RoleName,
    COALESCE(MP.ProjectNames, 'NULL') AS ProjectNames, -- Используем COALESCE для обработки случаев, когда проектов нет
    COALESCE(MT.TaskNames, 'NULL') AS TaskNames, -- Используем COALESCE для обработки случаев, когда задач нет
    COALESCE(MS.TotalSubordinates, 0) AS TotalSubordinates -- Используем COALESCE для обработки случаев, когда подчиненных нет
FROM EmployeeHierarchy EH
LEFT JOIN ManagerProjects MP ON EH.EmployeeID = MP.EmployeeID -- Соединяем результаты с проектами
LEFT JOIN ManagerTasks MT ON EH.EmployeeID = MT.EmployeeID -- Соединяем результаты с задачами
LEFT JOIN ManagerSubordinates MS ON EH.EmployeeID = MS.ManagerID -- Соединяем результаты с подсчетом подчиненных
WHERE MS.TotalSubordinates > 0 -- Фильтруем только тех менеджеров, у которых есть подчиненные
ORDER BY EH.EmployeeName; -- Сортируем результаты по имени сотрудника
