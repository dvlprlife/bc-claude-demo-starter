/// <summary>
/// Handles renewal eligibility checks, invoice creation, and date advancement
/// for support contracts. Supports both single-contract and batch renewal.
/// </summary>
codeunit 60102 "Support Contract Renewal Mgt."
{
    Permissions = tabledata "Support Contract" = rm,
                  tabledata "Support Contract Setup" = r,
                  tabledata "Sales Header" = rimd,
                  tabledata "Sales Line" = rimd;

    /// <summary>
    /// Renews a single contract: validates eligibility, creates a draft sales invoice,
    /// and advances contract dates by one year.
    /// </summary>
    /// <param name="SupportContract">The contract to renew.</param>
    procedure RenewSingleContract(var SupportContract: Record "Support Contract")
    var
        InvoiceNo: Code[20];
        RenewalCreatedMsg: Label 'Renewal invoice %1 has been created.', Comment = '%1 = Invoice No.';
    begin
        ValidateRenewalEligibility(SupportContract);
        InvoiceNo := CreateRenewalInvoice(SupportContract);
        AdvanceContractDates(SupportContract);
        Message(RenewalCreatedMsg, InvoiceNo);
    end;

    /// <summary>
    /// Processes all eligible contracts for renewal in batch.
    /// Errors on individual contracts do not block remaining contracts.
    /// </summary>
    procedure RenewAllEligible()
    var
        SupportContract: Record "Support Contract";
        EligibleCount: Integer;
        SuccessCount: Integer;
        ErrorCount: Integer;
        NoEligibleMsg: Label 'No contracts are currently eligible for renewal.';
        ConfirmBatchQst: Label '%1 contracts are eligible for renewal. Create invoices?', Comment = '%1 = Count';
        BatchResultMsg: Label '%1 invoices created. %2 contracts skipped due to errors.', Comment = '%1 = Success Count, %2 = Error Count';
    begin
        SupportContract.SetRange(Status, SupportContract.Status::Active);
        SupportContract.SetRange("Auto-Renew", true);

        // Count eligible contracts
        if SupportContract.FindSet() then
            repeat
                if IsEligibleForRenewal(SupportContract) then
                    EligibleCount += 1;
            until SupportContract.Next() = 0;

        if EligibleCount = 0 then begin
            Message(NoEligibleMsg);
            exit;
        end;

        if not Confirm(ConfirmBatchQst, false, EligibleCount) then
            exit;

        // Process renewals
        SupportContract.FindSet();
        repeat
            if IsEligibleForRenewal(SupportContract) then begin
                if TryRenewContract(SupportContract) then
                    SuccessCount += 1
                else
                    ErrorCount += 1;
            end;
        until SupportContract.Next() = 0;

        Message(BatchResultMsg, SuccessCount, ErrorCount);
    end;

    local procedure ValidateRenewalEligibility(SupportContract: Record "Support Contract")
    var
        Item: Record Item;
        Customer: Record Customer;
        SupportContractSetup: Record "Support Contract Setup";
        RenewalItemNo: Code[20];
        AlreadyRenewedErr: Label 'This contract has already been renewed. Last renewed: %1.', Comment = '%1 = Date';
        NoRenewalItemErr: Label 'A Renewal Item No. must be specified in the contract or Support Contract Setup.';
        ItemBlockedErr: Label 'Item %1 is blocked and cannot be used on invoices.', Comment = '%1 = Item No.';
        CustomerBlockedErr: Label 'Customer %1 is blocked. The renewal invoice cannot be created.', Comment = '%1 = Customer No.';
    begin
        SupportContract.TestField(Status, SupportContract.Status::Active);
        SupportContract.TestField("Auto-Renew", true);
        SupportContract.TestField("Customer No.");

        // Check not already renewed for current period
        if (SupportContract."Last Renewed Date" <> 0D) and
           (SupportContract."Last Renewed Date" >= SupportContract."End Date") then
            Error(AlreadyRenewedErr, SupportContract."Last Renewed Date");

        // Determine renewal item
        RenewalItemNo := SupportContract."Renewal Item No.";
        if RenewalItemNo = '' then begin
            SupportContractSetup.GetSetup();
            RenewalItemNo := SupportContractSetup."Renewal Item No.";
        end;
        if RenewalItemNo = '' then
            Error(NoRenewalItemErr);

        // Check item not blocked
        if Item.Get(RenewalItemNo) then
            if Item.Blocked then
                Error(ItemBlockedErr, RenewalItemNo);

        // Check customer not blocked
        if Customer.Get(SupportContract."Customer No.") then
            if Customer.Blocked <> Customer.Blocked::" " then
                Error(CustomerBlockedErr, SupportContract."Customer No.");
    end;

    local procedure IsEligibleForRenewal(SupportContract: Record "Support Contract"): Boolean
    begin
        if SupportContract.Status <> SupportContract.Status::Active then
            exit(false);
        if not SupportContract."Auto-Renew" then
            exit(false);
        if (SupportContract."Last Renewed Date" <> 0D) and
           (SupportContract."Last Renewed Date" >= SupportContract."End Date") then
            exit(false);
        exit(true);
    end;

    local procedure CreateRenewalInvoice(SupportContract: Record "Support Contract"): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SupportContractSetup: Record "Support Contract Setup";
        RenewalItemNo: Code[20];
        RenewalAmount: Decimal;
    begin
        SupportContractSetup.GetSetup();

        // Determine item and amount
        RenewalItemNo := SupportContract."Renewal Item No.";
        if RenewalItemNo = '' then
            RenewalItemNo := SupportContractSetup."Renewal Item No.";

        RenewalAmount := SupportContract."Renewal Amount";
        if RenewalAmount = 0 then
            RenewalAmount := SupportContractSetup."Default Renewal Amount";

        // Create Sales Invoice Header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", SupportContract."Customer No.");
        if SupportContract."External Document No." <> '' then
            SalesHeader."External Document No." := SupportContract."External Document No.";
        SalesHeader.Modify(true);

        // Create Sales Invoice Line
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", RenewalItemNo);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", RenewalAmount);
        SalesLine.Modify(true);

        exit(SalesHeader."No.");
    end;

    local procedure AdvanceContractDates(var SupportContract: Record "Support Contract")
    begin
        SupportContract."Start Date" := CalcDate('<1Y>', SupportContract."Start Date");
        SupportContract."End Date" := CalcDate('<1Y>', SupportContract."End Date");
        SupportContract."Last Renewed Date" := WorkDate();
        SupportContract.Modify(true);
    end;

    [TryFunction]
    local procedure TryRenewContract(var SupportContract: Record "Support Contract")
    begin
        ValidateRenewalEligibility(SupportContract);
        CreateRenewalInvoice(SupportContract);
        AdvanceContractDates(SupportContract);
    end;
}
