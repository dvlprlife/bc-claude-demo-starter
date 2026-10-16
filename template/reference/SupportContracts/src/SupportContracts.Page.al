/// <summary>
/// List page for browsing and filtering all support contracts.
/// Supports standard BC filtering, sorting, and Excel export.
/// </summary>
page 60102 "Support Contracts"
{
    Caption = 'Support Contracts';
    PageType = List;
    SourceTable = "Support Contract";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "Support Contract Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Contracts)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the contract number.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the customer linked to this contract.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("Service Level"; Rec."Service Level")
                {
                    ApplicationArea = All;
                    Caption = 'Service Level';
                    ToolTip = 'Specifies the support tier for this contract.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies the current status of the contract.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Caption = 'Start Date';
                    ToolTip = 'Specifies the date the contract coverage begins.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    Caption = 'End Date';
                    ToolTip = 'Specifies the date the contract coverage ends.';
                }
                field("Auto-Renew"; Rec."Auto-Renew")
                {
                    ApplicationArea = All;
                    Caption = 'Auto-Renew';
                    ToolTip = 'Specifies whether the contract is set to auto-renew.';
                }
                field("Renewal Amount"; Rec."Renewal Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Renewal Amount';
                    ToolTip = 'Specifies the renewal amount for this contract.';
                }
                field("Last Renewed Date"; Rec."Last Renewed Date")
                {
                    ApplicationArea = All;
                    Caption = 'Last Renewed Date';
                    ToolTip = 'Specifies the date this contract was last renewed.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RenewAllEligible)
            {
                ApplicationArea = All;
                Caption = 'Renew All Eligible';
                ToolTip = 'Processes renewal invoices for all eligible contracts.';
                Image = ExecuteBatch;

                trigger OnAction()
                var
                    SupportContractRenewalMgt: Codeunit "Support Contract Renewal Mgt.";
                begin
                    SupportContractRenewalMgt.RenewAllEligible();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(RenewAllEligible_Promoted; RenewAllEligible)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    local procedure SetStatusStyle()
    begin
        case Rec.GetEffectiveStatus() of
            Rec.Status::Draft:
                StatusStyleExpr := 'Standard';
            Rec.Status::Active:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Expired:
                StatusStyleExpr := 'Attention';
            Rec.Status::Cancelled:
                StatusStyleExpr := 'Unfavorable';
        end;
    end;

    var
        StatusStyleExpr: Text;
}
