module CreditSharedContexts
  shared_context "with unaccounted credit" do
    let!(:credit) { FactoryGirl.create(:credit, :amount => BigDecimal.new("100")) }

    def add_entry(debit = nil, amount = BigDecimal.new("0"))
      if debit.nil?
        entry = FactoryGirl.create(:entry, :credit => credit, :amount => amount)
      else
        entry = FactoryGirl.create(:entry, :credit => credit, :debit => debit, :amount => amount)
      end
    end
  end
  
  shared_context "with partially accounted credit" do
    let!(:credit) do
      credit = FactoryGirl.create(:credit, :amount => BigDecimal.new("100"))
      debit = FactoryGirl.create(:debit, :ledger => credit.ledger, :amount => BigDecimal.new("200"))
      entry = FactoryGirl.create(:entry, :ledger => credit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("10"))
      entry = FactoryGirl.create(:entry, :ledger => credit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("20"))
      credit.reload
    end
  end

  shared_context "with fully accounted credit" do
    let!(:credit) do
      credit = FactoryGirl.create(:credit, :amount => BigDecimal.new("100"))
      debit = FactoryGirl.create(:debit, :ledger => credit.ledger, :amount => BigDecimal.new("200"))
      entry = FactoryGirl.create(:entry, :ledger => credit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("10"))
      entry = FactoryGirl.create(:entry, :ledger => credit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("20"))
      entry = FactoryGirl.create(:entry, :ledger => credit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("70"))
      credit.reload
    end
  end
end