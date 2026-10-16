/// <summary>
/// Stores contract contact lines. Up to three contacts can be linked per contract.
/// Contacts must belong to the company contact associated with the contract's customer.
/// </summary>
table 60102 "Support Contract Contact"
{
    Caption = 'Support Contract Contact';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "Support Contract";
            ToolTip = 'Specifies the parent support contract number.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number for this contact entry.';
        }
        field(3; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = Contact;
            ToolTip = 'Specifies the contact linked to this support contract.';

            trigger OnValidate()
            var
                Contact: Record Contact;
                SupportContractContact: Record "Support Contract Contact";
                DuplicateContactErr: Label 'Contact %1 is already linked to this contract.', Comment = '%1 = Contact No.';
            begin
                if "Contact No." = '' then begin
                    "Contact Name" := '';
                    "Phone No." := '';
                    "E-Mail" := '';
                    exit;
                end;

                // Check for duplicate
                SupportContractContact.SetRange("Contract No.", "Contract No.");
                SupportContractContact.SetRange("Contact No.", "Contact No.");
                SupportContractContact.SetFilter("Line No.", '<>%1', "Line No.");
                if not SupportContractContact.IsEmpty() then
                    Error(DuplicateContactErr, "Contact No.");

                Contact.Get("Contact No.");
                "Contact Name" := Contact.Name;
                "Phone No." := Contact."Phone No.";
                "E-Mail" := Contact."E-Mail";
            end;

            trigger OnLookup()
            var
                SupportContract: Record "Support Contract";
                Contact: Record Contact;
                ContactBusinessRelation: Record "Contact Business Relation";
                ContactList: Page "Contact List";
            begin
                if SupportContract.Get("Contract No.") then begin
                    ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                    ContactBusinessRelation.SetRange("No.", SupportContract."Customer No.");
                    if ContactBusinessRelation.FindFirst() then begin
                        Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.");
                        ContactList.SetTableView(Contact);
                        ContactList.LookupMode(true);
                        if ContactList.RunModal() = Action::LookupOK then begin
                            ContactList.GetRecord(Contact);
                            Validate("Contact No.", Contact."No.");
                        end;
                    end;
                end;
            end;
        }
        field(4; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
            Editable = false;
            ToolTip = 'Specifies the name of the contact.';
        }
        field(5; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            Editable = false;
            ExtendedDatatype = PhoneNo;
            ToolTip = 'Specifies the phone number of the contact.';
        }
        field(6; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            Editable = false;
            ExtendedDatatype = EMail;
            ToolTip = 'Specifies the email address of the contact.';
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        SupportContractContact: Record "Support Contract Contact";
        MaxContactsErr: Label 'A maximum of 3 contacts are allowed per contract.';
    begin
        // Enforce maximum 3 contacts per contract
        SupportContractContact.SetRange("Contract No.", "Contract No.");
        if SupportContractContact.Count() >= 3 then
            Error(MaxContactsErr);

        // Auto-assign line number if not set
        if "Line No." = 0 then begin
            SupportContractContact.SetRange("Contract No.", "Contract No.");
            if SupportContractContact.FindLast() then
                "Line No." := SupportContractContact."Line No." + 10000
            else
                "Line No." := 10000;
        end;
    end;
}
