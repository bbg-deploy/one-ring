module DebitSharedContexts
  shared_context "with unaccounted debit" do
    let!(:debit) { FactoryGirl.create(:debit, :amount => BigDecimal.new("100")) }

    def add_entry(credit = nil, amount = BigDecimal.new("0"))
      if debit.nil?
        entry = FactoryGirl.create(:entry, :debit => debit, :amount => amount)
      else
        entry = FactoryGirl.create(:entry, :debit => debit, :credit => credit, :amount => amount)
      end
    end
  end
  
  shared_context "with partially accounted debit" do
    let!(:debit) do
      debit = FactoryGirl.create(:debit, :amount => BigDecimal.new("100"))
      credit = FactoryGirl.create(:credit, :ledger => debit.ledger, :amount => BigDecimal.new("200"))
      entry = FactoryGirl.create(:entry, :ledger => debit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("10"))
      entry = FactoryGirl.create(:entry, :ledger => debit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("20"))
      debit.reload
    end
  end

  shared_context "with fully accounted debit" do
    let!(:debit) do
      debit = FactoryGirl.create(:debit, :amount => BigDecimal.new("100"))
      credit = FactoryGirl.create(:credit, :ledger => debit.ledger, :amount => BigDecimal.new("200"))
      entry = FactoryGirl.create(:entry, :ledger => debit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("10"))
      entry = FactoryGirl.create(:entry, :ledger => debit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("20"))
      entry = FactoryGirl.create(:entry, :ledger => debit.ledger, :debit => debit, :credit => credit, :amount => BigDecimal.new("70"))
      debit.reload
    end
  end
end