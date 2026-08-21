CREATE PROCEDURE [dbo].[sp_GetUserById]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        UserId,
        Username,
        Email,
        FirstName,
        LastName,
        CreatedAt,
        IsActive
    FROM [dbo].[Users]
    WHERE UserId = @UserId;
END;
