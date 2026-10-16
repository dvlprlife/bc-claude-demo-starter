/// <summary>
/// Install codeunit that seeds the Support Contract Setup record on extension install.
/// </summary>
codeunit 60100 "Support Contract Install"
{
    Subtype = Install;
    Permissions = tabledata "Support Contract Setup" = rimd;

    trigger OnInstallAppPerCompany()
    var
        SupportContractSetup: Record "Support Contract Setup";
    begin
        if not SupportContractSetup.Get() then begin
            SupportContractSetup.Init();
            SupportContractSetup.Insert();
        end;
    end;
}
