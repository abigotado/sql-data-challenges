WITH RECURSIVE
    EmployeeHierarchy AS (
        -- Этот CTE строит иерархию сотрудников, начиная с Ивана Иванова (EmployeeID = 1), находя всех его подчиненных на разных уровнях.
        -- Базовый уровень: сам Иван Иванов
        SELECT
            E.EmployeeID, -- Идентификатор сотрудника
            E.Name AS EmployeeName, -- Имя сотрудника
            E.ManagerID, -- Идентификатор менеджера
            D.DepartmentName, -- Название отдела
            R.RoleName -- Название роли
        FROM
            Employees E
                JOIN Departments D ON E.DepartmentID = D.DepartmentID -- Используем JOIN для получения информации о департаменте
                JOIN Roles R ON E.RoleID = R.RoleID -- Используем JOIN для получения информации о роли
        WHERE
            E.EmployeeID = 1
        UNION ALL
        -- Рекурсивный шаг: подчиненные текущих сотрудников
        SELECT
            E.EmployeeID, -- Идентификатор сотрудника
            E.Name, -- Имя сотрудника
            E.ManagerID, -- Идентификатор менеджера
            D.DepartmentName, -- Название отдела
            R.RoleName -- Название роли
        FROM
            Employees E
                JOIN EmployeeHierarchy EH ON E.ManagerID = EH.EmployeeID
                JOIN Departments D ON E.DepartmentID = D.DepartmentID
                JOIN Roles R ON E.RoleID = R.RoleID
    ),
    -- Этот CTE определяет список всех проектов, в которых участвуют сотрудники, найденные в EmployeeHierarchy.
    EmployeeProjects AS (
        SELECT
            E.EmployeeID, -- Идентификатор сотрудника
            STRING_AGG(DISTINCT P.ProjectName, ', ') AS ProjectNames -- Названия проектов, агрегируемые в одну строку
        FROM
            Projects P
                JOIN Departments D ON P.DepartmentID = D.DepartmentID
                JOIN Employees E ON E.DepartmentID = D.DepartmentID
        WHERE
            E.EmployeeID IN (
                SELECT
                    EmployeeID
                FROM
                    EmployeeHierarchy
            ) -- Фильтруем сотрудников, чтобы получить только тех, кто в иерархии
        GROUP BY
            E.EmployeeID
    ),
    -- Этот CTE собирает список задач, назначенных сотрудникам из EmployeeHierarchy.
    EmployeeTasks AS (
        SELECT
            T.AssignedTo AS EmployeeID, -- Идентификатор сотрудника
            STRING_AGG(DISTINCT T.TaskName, ', ') AS TaskNames -- Названия задач, агрегируемые в одну строку
        FROM
            Tasks T
        WHERE
            T.AssignedTo IN (
                SELECT
                    EmployeeID
                FROM
                    EmployeeHierarchy
            )
        GROUP BY
            T.AssignedTo
    )
-- Этот запрос объединяет данные о сотрудниках, их департаментах, ролях, проектах и задачах.
SELECT
    EH.EmployeeID, -- Идентификатор сотрудника
    EH.EmployeeName, -- Имя сотрудника
    EH.ManagerID, -- Идентификатор менеджера
    EH.DepartmentName, -- Название отдела
    EH.RoleName, -- Название роли
    COALESCE(EP.ProjectNames, 'NULL') AS ProjectNames, -- Названия проектов, с использованием COALESCE для избежания NULL
    COALESCE(ET.TaskNames, 'NULL') AS TaskNames -- Названия задач, с использованием COALESCE для избежания NULL
FROM
    EmployeeHierarchy EH
        LEFT JOIN EmployeeProjects EP ON EH.EmployeeID = EP.EmployeeID
        LEFT JOIN EmployeeTasks ET ON EH.EmployeeID = ET.EmployeeID
ORDER BY
    EH.EmployeeName COLLATE "C"; -- Сортировка по имени строго по кодам символов ASCII/UTF-8 без учета языковых правил