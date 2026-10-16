/// <summary>
/// Defines the three service tiers available for support contracts.
/// </summary>
enum 60100 "Service Level"
{
    Extensible = false;
    Caption = 'Service Level';

    value(0; Standard)
    {
        Caption = 'Standard';
    }
    value(1; Expedited)
    {
        Caption = 'Expedited';
    }
    value(2; "Full Service")
    {
        Caption = 'Full Service';
    }
}
