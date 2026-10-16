/// <summary>
/// Card page for viewing and managing an individual support contract.
/// Provides actions for activation, cancellation, and renewal.
/// </summary>
page 60101 "Support Contract Card"
{
    Caption = 'Support Contract Card';
    PageType = Card;
    SourceTable = "Support Contract";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the contract number, auto-assigned from the configured number series.';

                    trigger OnAssistEdit()
                    var
                        SupportContractSetup: Record "Support Contract Setup";
                        NoSeries: Codeunit "No. Series";
                    begin
                        SupportContractSetup.GetSetup();
                        if NoSeries.LookupRelatedNoSeries(SupportContractSetup."Contract No. Series", Rec."No. Series") then begin
                            Rec."No." := NoSeries.GetNextNo(Rec."No. Series");
                            CurrPage.Update();
                        end;
                    end;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the customer linked to this support contract.';
                    Editable = Rec.Status = Rec.Status::Draft;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the name of the customer linked to this contract.';
                    Editable = false;
                }
                field("Service Level"; Rec."Service Level")
                {
                    ApplicationArea = All;
                    Caption = 'Service Level';
                    ToolTip = 'Specifies the support tier for this contract.';
                    Editable = IsEditable;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies the current lifecycle status of the contract.';
                    StyleExpr = StatusStyleExpr;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies free-text notes or special terms for the contract.';
                    Editable = IsEditable;
                    MultiLine = true;
                }
            }
            group(Dates)
            {
                Caption = 'Contract Dates';

                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Caption = 'Start Date';
                    ToolTip = 'Specifies the date the contract coverage begins.';
                    Editable = Rec.Status = Rec.Status::Draft;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    Caption = 'End Date';
                    ToolTip = 'Specifies the date the contract coverage ends.';
                    Editable = Rec.Status = Rec.Status::Draft;
                }
            }
            group(Renewal)
            {
                Caption = 'Renewal';

                field("Auto-Renew"; Rec."Auto-Renew")
                {
                    ApplicationArea = All;
                    Caption = 'Auto-Renew';
                    ToolTip = 'Specifies whether the contract should be automatically renewed.';
                    Editable = IsEditable;
                }
                field("Renewal Amount"; Rec."Renewal Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Renewal Amount';
                    ToolTip = 'Specifies the renewal amount for this contract. If blank, the default from setup is used.';
                    Editable = IsEditable;
                }
                field("Renewal Item No."; Rec."Renewal Item No.")
                {
                    ApplicationArea = All;
                    Caption = 'Renewal Item No.';
                    ToolTip = 'Specifies the item used on the renewal invoice line.';
                    Editable = IsEditable;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'External Document No.';
                    ToolTip = 'Specifies an external reference such as a purchase order number.';
                    Editable = IsEditable;
                }
                field("Last Renewed Date"; Rec."Last Renewed Date")
                {
                    ApplicationArea = All;
                    Caption = 'Last Renewed Date';
                    ToolTip = 'Specifies the date this contract was last renewed.';
                }
            }
            part(Contacts; "Support Contract Contacts")
            {
                ApplicationArea = All;
                Caption = 'Contacts';
                SubPageLink = "Contract No." = field("No.");
                Editable = IsEditable;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Activate)
            {
                ApplicationArea = All;
                Caption = 'Activate';
                ToolTip = 'Activates the draft contract, making it officially in effect.';
                Image = Approve;
                Enabled = Rec.Status = Rec.Status::Draft;
                Visible = Rec.Status = Rec.Status::Draft;

                trigger OnAction()
                begin
                    Rec.Activate();
                    CurrPage.Update(false);
                end;
            }
            action(CancelContract)
            {
                ApplicationArea = All;
                Caption = 'Cancel Contract';
                ToolTip = 'Cancels the contract. This action cannot be undone.';
                Image = Cancel;

                trigger OnAction()
                begin
                    Rec.Cancel();
                    CurrPage.Update(false);
                end;
            }
            action(RenewContract)
            {
                ApplicationArea = All;
                Caption = 'Renew Contract';
                ToolTip = 'Creates a renewal invoice and extends the contract dates by one year.';
                Image = Refresh;
                Enabled = (Rec.Status = Rec.Status::Active) and Rec."Auto-Renew";
                Visible = (Rec.Status = Rec.Status::Active) and Rec."Auto-Renew";

                trigger OnAction()
                var
                    SupportContractRenewalMgt: Codeunit "Support Contract Renewal Mgt.";
                begin
                    SupportContractRenewalMgt.RenewSingleContract(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Activate_Promoted; Activate)
                {
                }
                actionref(CancelContract_Promoted; CancelContract)
                {
                }
                actionref(RenewContract_Promoted; RenewContract)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsEditable := Rec.IsEditable();
        SetStatusStyle();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsEditable := true;
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
        IsEditable: Boolean;
        StatusStyleExpr: Text;
}
