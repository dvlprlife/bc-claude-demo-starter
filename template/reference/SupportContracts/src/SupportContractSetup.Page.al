/// <summary>
/// Card page for configuring extension-wide defaults before creating contracts.
/// Singleton pattern — only one setup record exists.
/// </summary>
page 60100 "Support Contract Setup"
{
    Caption = 'Support Contract Setup';
    PageType = Card;
    SourceTable = "Support Contract Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Contract No. Series"; Rec."Contract No. Series")
                {
                    ApplicationArea = All;
                    Caption = 'Contract No. Series';
                    ToolTip = 'Specifies the number series used for assigning contract numbers.';
                }
                field("Renewal Item No."; Rec."Renewal Item No.")
                {
                    ApplicationArea = All;
                    Caption = 'Renewal Item No.';
                    ToolTip = 'Specifies the item used on renewal invoice lines.';
                }
                field("Default Renewal Amount"; Rec."Default Renewal Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Default Renewal Amount';
                    ToolTip = 'Specifies the default unit price for renewal invoice lines. Can be overridden per contract.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
