/// <summary>
/// ListPart subpage for displaying contract contacts on the Support Contract Card.
/// Allows adding up to three contacts per contract.
/// </summary>
page 60103 "Support Contract Contacts"
{
    Caption = 'Support Contract Contacts';
    PageType = ListPart;
    SourceTable = "Support Contract Contact";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Contacts)
            {
                field("Contact No."; Rec."Contact No.")
                {
                    ApplicationArea = All;
                    Caption = 'Contact No.';
                    ToolTip = 'Specifies the contact linked to this support contract.';
                }
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = All;
                    Caption = 'Contact Name';
                    ToolTip = 'Specifies the name of the contact.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    Caption = 'Phone No.';
                    ToolTip = 'Specifies the phone number of the contact.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    Caption = 'E-Mail';
                    ToolTip = 'Specifies the email address of the contact.';
                }
            }
        }
    }
}
