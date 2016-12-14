﻿IF OBJECT_ID('finance.get_frequency_setup_start_date_frequency_setup_id') IS NOT NULL
DROP FUNCTION finance.get_frequency_setup_start_date_frequency_setup_id;

GO

CREATE FUNCTION finance.get_frequency_setup_start_date_frequency_setup_id(@frequency_setup_id integer)
RETURNS date
AS
BEGIN
    DECLARE @start_date date;

    SELECT MAX(value_date) + 1 
    INTO @start_date
    FROM finance.frequency_setups
    WHERE finance.frequency_setups.value_date < 
    (
        SELECT value_date
        FROM finance.frequency_setups
        WHERE finance.frequency_setups.frequency_setup_id = @frequency_setup_id
        AND finance.frequency_setups.deleted = 0
    )
    AND finance.frequency_setups.deleted = 0;

    IF(@start_date IS NULL)
    BEGIN
        SELECT starts_from 
        INTO @start_date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
    END;

    RETURN @start_date;
END;

GO
