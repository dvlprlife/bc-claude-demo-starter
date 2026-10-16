/// <summary>
/// Defines the lifecycle statuses for a support contract.
/// </summary>
enum 60101 "Contract Status"
{
    Extensible = false;
    Caption = 'Contract Status';

    value(0; Draft)
    {
        Caption = 'Draft';
    }
    value(1; Active)
    {
        Caption = 'Active';
    }
    value(2; Expired)
    {
        Caption = 'Expired';
    }
    value(3; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
