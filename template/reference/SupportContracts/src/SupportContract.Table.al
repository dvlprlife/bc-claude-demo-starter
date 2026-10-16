/// <summary>
/// Main table for support contracts. Each record represents a support agreement
/// with a customer, including service level, dates, status, and renewal settings.
/// </summary>
table 60101 "Support Contract"
{
    Caption = 'Support Contract';
    DataClassification = CustomerContent;
    LookupPageId = "Support Contracts";
    DrillDownPageId = "Support Contracts";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the contract number, auto-assigned from the configured number series.';

            trigger OnValidate()
            var
                SupportContractSetup: Record "Support Contract Setup";
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    SupportContractSetup.GetSetup();
                    NoSeries.TestManual(SupportContractSetup."Contract No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            ToolTip = 'Specifies the customer linked to this support contract.';

            trigger OnValidate()
            var
                Customer: Record Customer;
                SupportContractContact: Record "Support Contract Contact";
                ConfirmChangeQst: Label 'Changing the customer will remove all linked contacts. Continue?';
            begin
                if "Customer No." <> xRec."Customer No." then begin
                    if "Customer No." = '' then begin
                        "Customer Name" := '';
                        exit;
                    end;

                    // Warn and clear contacts if customer changed on existing record
                    if (xRec."Customer No." <> '') and (CurrFieldNo <> 0) then begin
                        SupportContractContact.SetRange("Contract No.", "No.");
                        if not SupportContractContact.IsEmpty() then begin
                            if not Confirm(ConfirmChangeQst) then
                                Error('');
                            SupportContractContact.DeleteAll(true);
                        end;
                    end;
                end;

                if "Customer No." <> '' then begin
                    Customer.Get("Customer No.");
                    "Customer Name" := Customer.Name;
                    if Customer.Blocked <> Customer.Blocked::" " then
                        Message(CustomerBlockedMsg, "Customer No.");
                end else
                    "Customer Name" := '';
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = Normal;
            ToolTip = 'Specifies the name of the customer linked to this contract.';
        }
        field(4; "Service Level"; Enum "Service Level")
        {
            Caption = 'Service Level';
            ToolTip = 'Specifies the support tier for this contract: Standard, Expedited, or Full Service.';

            trigger OnValidate()
            var
                ConfirmServiceLevelQst: Label 'Changing the service level on an active contract may affect support obligations. Continue?';
            begin
                if (Status = Status::Active) and ("Service Level" <> xRec."Service Level") then
                    if not Confirm(ConfirmServiceLevelQst) then
                        Error('');
            end;
        }
        field(5; Status; Enum "Contract Status")
        {
            Caption = 'Status';
            Editable = false;
            ToolTip = 'Specifies the current lifecycle status of the contract.';
        }
        field(6; "Start Date"; Date)
        {
            Caption = 'Start Date';
            ToolTip = 'Specifies the date the contract coverage begins.';

            trigger OnValidate()
            begin
                if ("Start Date" <> 0D) and ("End Date" <> 0D) then
                    if "Start Date" > "End Date" then
                        Error(StartDateAfterEndDateErr);
            end;
        }
        field(7; "End Date"; Date)
        {
            Caption = 'End Date';
            ToolTip = 'Specifies the date the contract coverage ends.';

            trigger OnValidate()
            begin
                if ("Start Date" <> 0D) and ("End Date" <> 0D) then
                    if "Start Date" > "End Date" then
                        Error(StartDateAfterEndDateErr);
            end;
        }
        field(8; "Auto-Renew"; Boolean)
        {
            Caption = 'Auto-Renew';
            ToolTip = 'Specifies whether the contract should be automatically renewed at the end of its period.';
        }
        field(9; "Renewal Amount"; Decimal)
        {
            Caption = 'Renewal Amount';
            MinValue = 0;
            ToolTip = 'Specifies the renewal amount for this contract. If blank, the default from setup is used.';
        }
        field(10; "Renewal Item No."; Code[20])
        {
            Caption = 'Renewal Item No.';
            TableRelation = Item;
            ToolTip = 'Specifies the item used on the renewal invoice line. If blank, the default from setup is used.';
        }
        field(11; "External Document No."; Text[35])
        {
            Caption = 'External Document No.';
            ToolTip = 'Specifies an external reference such as a purchase order number, carried to renewal invoices.';
        }
        field(12; "Last Renewed Date"; Date)
        {
            Caption = 'Last Renewed Date';
            Editable = false;
            ToolTip = 'Specifies the date this contract was last renewed.';
        }
        field(13; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies free-text notes or special terms for the contract.';
        }
        field(14; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(CustomerNo; "Customer No.")
        {
        }
        key(EndDate; "End Date")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Customer Name", "Service Level", Status)
        {
        }
    }

    trigger OnInsert()
    var
        SupportContractSetup: Record "Support Contract Setup";
        NoSeries: Codeunit "No. Series";
        SetupIncompleteErr: Label 'Please complete the Support Contract Setup before creating contracts.';
    begin
        if "No." = '' then begin
            SupportContractSetup.GetSetup();
            SupportContractSetup.TestField("Contract No. Series", SetupIncompleteErr);
            "No." := NoSeries.GetNextNo(SupportContractSetup."Contract No. Series");
            "No. Series" := SupportContractSetup."Contract No. Series";
        end;

        // Default renewal fields from setup
        if "Renewal Amount" = 0 then begin
            SupportContractSetup.GetSetup();
            "Renewal Amount" := SupportContractSetup."Default Renewal Amount";
        end;
        if "Renewal Item No." = '' then begin
            SupportContractSetup.GetSetup();
            "Renewal Item No." := SupportContractSetup."Renewal Item No.";
        end;
    end;

    trigger OnDelete()
    var
        SupportContractContact: Record "Support Contract Contact";
    begin
        SupportContractContact.SetRange("Contract No.", "No.");
        SupportContractContact.DeleteAll(true);
    end;

    /// <summary>
    /// Activates a draft contract after validating all mandatory fields.
    /// </summary>
    procedure Activate()
    var
        MissingFields: Text;
        MandatoryFieldsMissingErr: Label 'The following mandatory fields must have a value before activation: %1';
    begin
        TestField(Status, Status::Draft);

        if "Customer No." = '' then
            MissingFields += 'Customer No., ';
        if "Service Level".AsInteger() < 0 then
            MissingFields += 'Service Level, ';
        if "Start Date" = 0D then
            MissingFields += 'Start Date, ';
        if "End Date" = 0D then
            MissingFields += 'End Date, ';

        if MissingFields <> '' then begin
            MissingFields := MissingFields.TrimEnd(', ');
            Error(MandatoryFieldsMissingErr, MissingFields);
        end;

        Status := Status::Active;
        Modify(true);
    end;

    /// <summary>
    /// Cancels a contract (from Draft or Active). This is irreversible.
    /// </summary>
    procedure Cancel()
    var
        ConfirmCancelQst: Label 'Are you sure you want to cancel this contract? This action cannot be undone.';
    begin
        if not (Status in [Status::Draft, Status::Active]) then
            Error(CannotCancelErr);

        if not Confirm(ConfirmCancelQst) then
            exit;

        Status := Status::Cancelled;
        "Auto-Renew" := false;
        Modify(true);
    end;

    /// <summary>
    /// Returns true if the contract is editable based on its current status.
    /// Expired and Cancelled contracts are read-only.
    /// </summary>
    /// <returns>True if the contract allows field edits.</returns>
    procedure IsEditable(): Boolean
    begin
        exit(Status in [Status::Draft, Status::Active]);
    end;

    /// <summary>
    /// Returns the effective status, considering expiry by date.
    /// An Active contract past its End Date is considered Expired.
    /// </summary>
    /// <returns>The effective contract status.</returns>
    procedure GetEffectiveStatus(): Enum "Contract Status"
    begin
        if (Status = Status::Active) and ("End Date" <> 0D) and ("End Date" < WorkDate()) then
            exit(Status::Expired);
        exit(Status);
    end;

    var
        StartDateAfterEndDateErr: Label 'Start Date must be on or before End Date.';
        CustomerBlockedMsg: Label 'Customer %1 is blocked.', Comment = '%1 = Customer No.';
        CannotCancelErr: Label 'Only Draft or Active contracts can be cancelled.';
}
