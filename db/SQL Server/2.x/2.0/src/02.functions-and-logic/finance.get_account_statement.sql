﻿IF OBJECT_ID('finance.get_account_statement') IS NOT NULL
DROP FUNCTION finance.get_account_statement;

GO

CREATE FUNCTION finance.get_account_statement
(
    @value_date_from        date,
    @value_date_to          date,
    @user_id                integer,
    @account_id             integer,
    @office_id              integer
)
RETURNS @result TABLE
(
    id                      integer,
    value_date              date,
    book_date               date,
    tran_code               national character varying(50),
    reference_number        national character varying(24),
    statement_reference     national character varying(2000),
    debit                   decimal(24, 4),
    credit                  decimal(24, 4),
    balance                 decimal(24, 4),
    office national character varying(1000),
    book                    national character varying(50),
    account_id              integer,
    account_number national character varying(24),
    account                 national character varying(1000),
    posted_on               DATETIMEOFFSET,
    posted_by               national character varying(1000),
    approved_by             national character varying(1000),
    verification_status     integer,
    flag_bg                 national character varying(1000),
    flag_fg                 national character varying(1000)
)
AS
BEGIN
    DECLARE @normally_debit bit;

    @normally_debit             = finance.is_normally_debit(@account_id);

    INSERT INTO @result(value_date, book_date, tran_code, reference_number, statement_reference, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
        @value_date_from,
        @value_date_from,
        NULL,
        NULL,
        'Opening Balance',
        NULL,
        SUM
        (
            CASE finance.transaction_details.tran_type
            WHEN 'Cr' THEN amount_in_local_currency
            ELSE amount_in_local_currency * -1 
            END            
        ) as credit,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    FROM finance.transaction_master
    INNER JOIN finance.transaction_details
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date < @value_date_from
    AND finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id)) 
    AND finance.transaction_details.account_id IN (SELECT * FROM finance.get_account_ids(@account_id))
    AND finance.transaction_master.deleted = 0;

    DELETE FROM @result
    WHERE COALESCE(debit, 0) = 0
    AND COALESCE(credit, 0) = 0;
    

    UPDATE @result SET 
    debit = credit * -1,
    credit = 0
    WHERE credit < 0;
    

    INSERT INTO @result(value_date, book_date, tran_code, reference_number, statement_reference, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master. transaction_code,
        finance.transaction_master.reference_number,
        finance.transaction_details.statement_reference,
        CASE finance.transaction_details.tran_type
        WHEN 'Dr' THEN amount_in_local_currency
        ELSE NULL END,
        CASE finance.transaction_details.tran_type
        WHEN 'Cr' THEN amount_in_local_currency
        ELSE NULL END,
        core.get_office_name_by_office_id(finance.transaction_master.office_id),
        finance.transaction_master.book,
        finance.transaction_details.account_id,
        finance.transaction_master.transaction_ts,
        account.get_name_by_user_id(finance.transaction_master.user_id),
        account.get_name_by_user_id(finance.transaction_master.verified_by_user_id),
        finance.transaction_master.verification_status_id
    FROM finance.transaction_master
    INNER JOIN finance.transaction_details
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date >= @value_date_from
    AND finance.transaction_master.value_date <= @value_date_to
    AND finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id)) 
    AND finance.transaction_details.account_id IN (SELECT * FROM finance.get_account_ids(@account_id))
    AND finance.transaction_master.deleted = 0
    ORDER BY 
        finance.transaction_master.book_date,
        finance.transaction_master.value_date,
        finance.transaction_master.last_verified_on;



    UPDATE @result
    SET balance = c.balance
    FROM
    (
        SELECT
            temp_account_statement.id, 
            SUM(COALESCE(c.credit, 0)) 
            - 
            SUM(COALESCE(c.debit,0)) As balance
        FROM @result AS temp_account_statement
        LEFT JOIN @result AS c 
            ON (c.id <= temp_account_statement.id)
        GROUP BY temp_account_statement.id
        ORDER BY temp_account_statement.id
    ) AS c
    WHERE id = c.id;


    UPDATE @result SET 
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name
    FROM finance.accounts
    WHERE account_id = finance.accounts.account_id;


--     UPDATE temp_account_statement SET
--         flag_bg = core.get_flag_background_color(core.get_flag_type_id(@user_id, 'account_statement', 'transaction_code', temp_account_statement.tran_code)),
--         flag_fg = core.get_flag_foreground_color(core.get_flag_type_id(@user_id, 'account_statement', 'transaction_code', temp_account_statement.tran_code));


    IF(@normally_debit)
    BEGIN
        UPDATE @result SET balance = balance * -1;
    END;

    RETURN;
END;



--SELECT * FROM finance.get_account_statement('1-1-2010','1-1-2020',1,1,1);


GO
