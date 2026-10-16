/// <summary>
/// Upgrade codeunit for handling data migration in future schema changes.
/// </summary>
codeunit 60101 "Support Contract Upgrade"
{
    Subtype = Upgrade;
    Permissions = tabledata "Support Contract Setup" = rimd,
                  tabledata "Support Contract" = rimd,
                  tabledata "Support Contract Contact" = rimd;

    trigger OnUpgradePerCompany()
    begin
        // Future upgrade logic goes here.
        // Example: migrate data when fields are added, renamed, or types changed.
    end;
}
