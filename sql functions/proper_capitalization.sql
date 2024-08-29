
CREATE FUNCTION dbo.PROPER_CASE(@input_string VARCHAR(255))
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @result_string VARCHAR(255) = LOWER(@input_string);  -- turn everything to lower case first
    DECLARE @index INT = 1;  
    
    
    SET @result_string = STUFF(@result_string, @index, 1, UPPER(SUBSTRING(@result_string, @index, 1)));
    
    -- Search for inner white spaces
    WHILE CHARINDEX(' ', @result_string, @index + 1) > 0
    BEGIN
        SET @index = CHARINDEX(' ', @result_string, @index + 1) + 1;  
        SET @result_string = STUFF(@result_string, @index, 1, UPPER(SUBSTRING(@result_string, @index, 1)));  
    END

    RETURN @result_string;  
END;
