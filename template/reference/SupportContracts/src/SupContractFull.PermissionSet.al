/// <summary>
/// Full access permission set for all Support Contract objects.
/// </summary>
permissionset 60100 "Sup. Contract - Full"
{
    Caption = 'Support Contract - Full Access';
    Assignable = true;

    Permissions = table "Support Contract Setup" = X,
                  table "Support Contract" = X,
                  table "Support Contract Contact" = X,
                  tabledata "Support Contract Setup" = RIMD,
                  tabledata "Support Contract" = RIMD,
                  tabledata "Support Contract Contact" = RIMD,
                  page "Support Contract Setup" = X,
                  page "Support Contract Card" = X,
                  page "Support Contracts" = X,
                  page "Support Contract Contacts" = X,
                  codeunit "Support Contract Renewal Mgt." = X;
}
