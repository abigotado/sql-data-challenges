-- Рекурсивно находим всех подчиненных сотрудников Ивана Иванова (EmployeeID = 1)
WITH RECURSIVE employee_hierarchy AS (
    -- Базовый уровень: включаем самого Ивана Иванова
    SELECT
        e.employeeid,  -- ID сотрудника
        e.name AS employeename,  -- Имя сотрудника
        e.managerid,  -- ID руководителя
        d.departmentname,  -- Название отдела
        r.rolename  -- Должность
    FROM employees e
    JOIN departments d ON e.departmentid = d.departmentid  -- Объединяем с таблицей отделов по ID отдела
    JOIN roles r ON e.roleid = r.roleid  -- Объединяем с таблицей ролей по ID роли
    WHERE e.employeeid = 1  -- Иван Иванов

    UNION ALL

    -- Рекурсивный шаг: включаем подчиненных найденных сотрудников
    SELECT
        e.employeeid,  -- ID подчиненного сотрудника
        e.name,  -- Имя подчиненного сотрудника
        e.managerid,  -- ID руководителя подчиненного
        d.departmentname,  -- Название отдела подчиненного
        r.rolename  -- Должность подчиненного
    FROM employees e
    JOIN employee_hierarchy eh ON e.managerid = eh.employeeid  -- Объединяем с предыдущим уровнем иерархии по ID руководителя
    JOIN departments d ON e.departmentid = d.departmentid  -- Объединяем с таблицей отделов по ID отдела
    JOIN roles r ON e.roleid = r.roleid  -- Объединяем с таблицей ролей по ID роли
),

-- Определяем список проектов для каждого сотрудника
employee_projects AS (
    SELECT
        e.employeeid,  -- ID сотрудника
        STRING_AGG(DISTINCT p.projectname, ', ') AS projectnames  -- Объединяем уникальные названия проектов через запятую
    FROM projects p
    JOIN employees e ON e.departmentid = p.departmentid  -- Объединяем с таблицей сотрудников по ID отдела
    WHERE e.employeeid IN (SELECT employeeid FROM employee_hierarchy)  -- Фильтруем по сотрудникам из иерархии
    GROUP BY e.employeeid  -- Группируем по ID сотрудника
),

-- Определяем список задач для каждого сотрудника
employee_tasks AS (
    SELECT
        t.assignedto AS employeeid,  -- ID сотрудника, которому назначена задача
        STRING_AGG(DISTINCT t.taskname, ', ') AS tasknames,  -- Объединяем уникальные названия задач через запятую
        COUNT(t.taskid) AS totaltasks  -- Подсчитываем количество задач
    FROM tasks t
    WHERE t.assignedto IN (SELECT employeeid FROM employee_hierarchy)  -- Фильтруем по сотрудникам из иерархии
    GROUP BY t.assignedto  -- Группируем по ID сотрудника
),

-- Определяем количество непосредственных подчиненных для каждого сотрудника
employee_subordinates AS (
    SELECT
        managerid,  -- ID руководителя
        COUNT(employeeid) AS totalsubordinates  -- Подсчитываем количество сотрудников, подчиненных данному менеджеру
    FROM employees
    WHERE managerid IN (SELECT employeeid FROM employee_hierarchy)  -- Фильтруем по сотрудникам из иерархии
    GROUP BY managerid  -- Группируем по ID руководителя
)

-- Объединяем всю информацию о сотрудниках, их проектах, задачах и количестве подчиненных
SELECT
    eh.employeeid,  -- ID сотрудника
    eh.employeename,  -- Имя сотрудника
    eh.managerid,  -- ID руководителя
    eh.departmentname,  -- Название отдела
    eh.rolename,  -- Должность
    COALESCE(ep.projectnames, 'NULL') AS projectnames,  -- Список проектов (если нет - NULL)
    COALESCE(et.tasknames, 'NULL') AS tasknames,  -- Список задач (если нет - NULL)
    COALESCE(et.totaltasks, 0) AS totaltasks,  -- Количество задач (если нет - 0)
    COALESCE(es.totalsubordinates, 0) AS totalsubordinates  -- Количество подчиненных (если нет - 0)
FROM employee_hierarchy eh
LEFT JOIN employee_projects ep ON eh.employeeid = ep.employeeid  -- Объединяем с проектами по ID сотрудника
LEFT JOIN employee_tasks et ON eh.employeeid = et.employeeid  -- Объединяем с задачами по ID сотрудника
LEFT JOIN employee_subordinates es ON eh.employeeid = es.managerid  -- Объединяем с подчиненными по ID руководителя
ORDER BY eh.employeename COLLATE "C";  -- Сортировка по имени сотрудника
