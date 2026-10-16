/// <summary>
/// Singleton setup table for the Support Contracts extension.
/// Stores extension-wide defaults for number series, renewal item, and renewal amount.
/// </summary>
table 60100 "Support Contract Setup"
{
    Caption = 'Support Contract Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Contract No. Series"; Code[20])
        {
            Caption = 'Contract No. Series';
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series used for assigning contract numbers.';
        }
        field(3; "Renewal Item No."; Code[20])
        {
            Caption = 'Renewal Item No.';
            TableRelation = Item where(Blocked = const(false));
            ToolTip = 'Specifies the item used on renewal invoice lines.';
        }
        field(4; "Default Renewal Amount"; Decimal)
        {
            Caption = 'Default Renewal Amount';
            MinValue = 0;
            ToolTip = 'Specifies the default unit price for renewal invoice lines. Can be overridden per contract.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Retrieves the singleton setup record, inserting it if it does not exist.
    /// </summary>
    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
