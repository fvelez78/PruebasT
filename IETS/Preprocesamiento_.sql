-- PROCESAMIENTO TABLA Municipios
--------------------------------------------------------------------------------------------------

-- Dado que las columnas Municipio y Departamento estan contaminadas por caracteres especiales
-- se prefiere eliminarlas y traerlas de otra fuente incluyendo el código de departamento.

-- Eliminacion de columnas Municipio y Departamento de la tabla Municipios

ALTER TABLE Municipios DROP COLUMN Municipio;
ALTER TABLE Municipios DROP COLUMN Departamento;
ALTER TABLE Municipios DROP COLUMN DP;

-- Se agrega la informacion de la tabla DIVIPOLA a la tabla Municipios

ALTER TABLE Municipios ADD COLUMN MUNICIPIO TEXT;
ALTER TABLE Municipios ADD COLUMN Cod_Dep TEXT;
ALTER TABLE Municipios ADD COLUMN DPTO TEXT;

UPDATE Municipios
SET 
    MUNICIPIO = (SELECT d.MUNICIPIO FROM DIVIPOLA d WHERE d.DIVIPOLA = Municipios.MPIO),
    Cod_Dep = (SELECT d.Cód_Dep FROM DIVIPOLA d WHERE d.DIVIPOLA = Municipios.MPIO),
    DPTO = (SELECT d.DPTO FROM DIVIPOLA d WHERE d.DIVIPOLA = Municipios.MPIO);

-- Consulta de verificacion    
SELECT * FROM Municipios;

-- PROCESAMIENTO TABLA Prestadores
--------------------------------------------------------------------------------------------------

-- Eliminacion de variable vacias o no informativas
ALTER TABLE Prestadores DROP COLUMN fecha_corte_REPS;
ALTER TABLE Prestadores DROP COLUMN tido_codigo;
ALTER TABLE Prestadores DROP COLUMN gerente;
ALTER TABLE Prestadores DROP COLUMN depa_nombre;
ALTER TABLE Prestadores DROP COLUMN muni_nombre;

-- Se extrae de la columna codigo_habilitacion el codigo del municipio
ALTER TABLE Prestadores ADD COLUMN MPIO INTEGER;
UPDATE Prestadores
SET MPIO = CAST(SUBSTR(codigo_habilitacion, 1, 5) AS INTEGER);

SELECT p.MPIO, p.[Municipio PDET],p.[Municipio ZOMAC],p.[Municipio PNIS],
       p.[Municipio PNSR antes 2023],p.[Municipio PNSR 2023],p.[Municipio PNSR 2024]
FROM Prestadores as p
GROUP BY p.MPIO

-- Las columnas al final del dataset Prestadores corresponden a caranteristicas de 
-- los municipios, siendo redundante registrar esos datos alli, por lo cual lo más
-- eficiente es hacer tal identificacion en la tabla Municipios y eliminar dichas
-- columnas del dataset Prestadores.

-- Se crean las columnas respectivas en la tabla Municipios
ALTER TABLE Municipios ADD COLUMN PDET INTEGER;
ALTER TABLE Municipios ADD COLUMN ZOMAC INTEGER;
ALTER TABLE Municipios ADD COLUMN PNIS INTEGER;
ALTER TABLE Municipios ADD COLUMN PNSR_antes_2023 INTEGER;
ALTER TABLE Municipios ADD COLUMN PNSR_2023 INTEGER;
ALTER TABLE Municipios ADD COLUMN PNSR_2024 INTEGER;

-- Se actualizan los valores de esas columnas nuevas registrando
-- 1 para SI y 0 para NO.
UPDATE Municipios
SET 
    PDET = (
        SELECT MAX(CASE WHEN [Municipio PDET] = 'SI' THEN 1 ELSE 0 END)
        FROM Prestadores
        WHERE Prestadores.MPIO = Municipios.MPIO
        GROUP BY MPIO
    ),
    ZOMAC = (
        SELECT MAX(CASE WHEN [Municipio ZOMAC] = 'SI' THEN 1 ELSE 0 END)
        FROM Prestadores
        WHERE Prestadores.MPIO = Municipios.MPIO
        GROUP BY MPIO
    ),
    PNIS = (
        SELECT MAX(CASE WHEN [Municipio PNIS] = 'SI' THEN 1 ELSE 0 END)
        FROM Prestadores
        WHERE Prestadores.MPIO = Municipios.MPIO
        GROUP BY MPIO
    ),
    PNSR_antes_2023 = (
        SELECT MAX(CASE WHEN [Municipio PNSR antes 2023] = 'SI' THEN 1 ELSE 0 END)
        FROM Prestadores
        WHERE Prestadores.MPIO = Municipios.MPIO
        GROUP BY MPIO
    ),
    PNSR_2023 = (
        SELECT MAX(CASE WHEN [Municipio PNSR 2023] = 'SI' THEN 1 ELSE 0 END) 
        FROM Prestadores
        WHERE Prestadores.MPIO = Municipios.MPIO
        GROUP BY MPIO
    ),
    PNSR_2024 = (
        SELECT MAX(CASE WHEN [Municipio PNSR 2024] = 'SI' THEN 1 ELSE 0 END)
        FROM Prestadores
        WHERE Prestadores.MPIO = Municipios.MPIO
        GROUP BY MPIO
    );

-- Para los casos donde los municipios quedan en NULL se completa a 0.
UPDATE Municipios SET PDET = 0 WHERE PDET IS NULL;
UPDATE Municipios SET ZOMAC = 0 WHERE ZOMAC IS NULL;
UPDATE Municipios SET PNIS = 0 WHERE PNIS IS NULL;
UPDATE Municipios SET PNSR_antes_2023 = 0 WHERE PNSR_antes_2023 IS NULL;
UPDATE Municipios SET PNSR_2023 = 0 WHERE PNSR_2023 IS NULL;
UPDATE Municipios SET PNSR_2024 = 0 WHERE PNSR_2024 IS NULL;

-- Finalmente se eliminan las variables de Prestadores
ALTER TABLE Prestadores DROP COLUMN [Municipio PDET];
ALTER TABLE Prestadores DROP COLUMN [Municipio ZOMAC];
ALTER TABLE Prestadores DROP COLUMN [Municipio PNIS];
ALTER TABLE Prestadores DROP COLUMN [Municipio PNSR antes 2023];
ALTER TABLE Prestadores DROP COLUMN [Municipio PNSR 2023];
ALTER TABLE Prestadores DROP COLUMN [Municipio PNSR 2024];

--=====================================================================================