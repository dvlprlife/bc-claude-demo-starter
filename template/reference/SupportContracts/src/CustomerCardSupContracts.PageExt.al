/// <summary>
/// Extends the standard Customer Card to add navigation to support contracts.
/// </summary>
pageextension 60100 "Customer Card Sup. Contracts" extends "Customer Card"
{
    actions
    {
        addlast(Navigation)
        {
            action(SupportContracts)
            {
                ApplicationArea = All;
                Caption = 'Support Contracts';
                ToolTip = 'View all support contracts for this customer.';
                Image = ServiceAgreement;
                RunObject = page "Support Contracts";
                RunPageLink = "Customer No." = field("No.");
            }
        }
        addlast(Category_Category9)
        {
            actionref(SupportContracts_Promoted; SupportContracts)
            {
            }
        }
    }
}
