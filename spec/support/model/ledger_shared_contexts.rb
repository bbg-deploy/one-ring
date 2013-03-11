module LedgerSharedContexts
  shared_context "with empty ledger" do
    let!(:ledger) { FactoryGirl.create(:ledger) }

    def add_debit(date = 1.day.ago, amount = BigDecimal.new("0"))
      debit = FactoryGirl.create(:debit, :ledger => ledger, :date => date, :amount => amount)
    end
  
    def add_credit(date = 1.day.ago, amount = BigDecimal.new("0"))
      credit = FactoryGirl.create(:credit, :ledger => ledger, :date => date, :amount => amount)
    end
    
    def delete_first_entry
      ledger.debits.first.entries.first.destroy
      return true
    end
  end
  
  shared_context "with unaccounted ledger" do
    let!(:ledger) { FactoryGirl.create(:ledger) }
    let!(:debit_1) { FactoryGirl.create(:debit, :ledger => ledger, :date => 6.days.ago, :amount => BigDecimal.new("100")) }
    let!(:debit_2) { FactoryGirl.create(:debit, :ledger => ledger, :date => 4.days.ago, :amount => BigDecimal.new("10")) }
    let!(:debit_3) { FactoryGirl.create(:debit, :ledger => ledger, :date => 2.days.ago, :amount => BigDecimal.new("50")) }
    let!(:credit_1) { FactoryGirl.create(:credit, :ledger => ledger, :date => 5.days.ago, :amount => BigDecimal.new("120")) }
    let!(:credit_2) { FactoryGirl.create(:credit, :ledger => ledger, :date => 4.day.ago, :amount => BigDecimal.new("10")) }

    def add_debit(date = 1.day.ago, amount = BigDecimal.new("0"))
      debit = FactoryGirl.create(:debit, :ledger => ledger, :date => date, :amount => amount)
    end
  
    def add_credit(date = 1.day.ago, amount = BigDecimal.new("0"))
      credit = FactoryGirl.create(:credit, :ledger => ledger, :date => date, :amount => amount)
    end

    def delete_first_entry
      entry = ledger.debits.first.entries.first
      entry.destroy unless entry.nil?
      return true
    end
  end

  shared_context "with accounted ledger" do
    let!(:ledger) { FactoryGirl.create(:ledger) }
    let!(:debit_1) { FactoryGirl.create(:debit, :ledger => ledger, :date => 6.days.ago, :amount => BigDecimal.new("100")) }
    let!(:debit_2) { FactoryGirl.create(:debit, :ledger => ledger, :date => 4.days.ago, :amount => BigDecimal.new("10")) }
    let!(:debit_3) { FactoryGirl.create(:debit, :ledger => ledger, :date => 2.days.ago, :amount => BigDecimal.new("50")) }
    let!(:credit_1) { FactoryGirl.create(:credit, :ledger => ledger, :date => 5.days.ago, :amount => BigDecimal.new("120")) }
    let!(:credit_2) { FactoryGirl.create(:credit, :ledger => ledger, :date => 4.day.ago, :amount => BigDecimal.new("10")) }

    before(:each) do
      ledger.do_accounting!
    end

    def add_debit(date = 1.day.ago, amount = BigDecimal.new("0"))
      debit = FactoryGirl.create(:debit, :ledger => ledger, :date => date, :amount => amount)
    end
  
    def add_credit(date = 1.day.ago, amount = BigDecimal.new("0"))
      credit = FactoryGirl.create(:credit, :ledger => ledger, :date => date, :amount => amount)
    end

    def delete_first_entry
      entry = ledger.debits.first.entries.first
      entry.destroy unless entry.nil?
      return true
    end
  end

  shared_context "with invalid accounted ledger" do
    let!(:ledger) { FactoryGirl.create(:ledger) }
    let!(:debit_1) { FactoryGirl.create(:debit, :ledger => ledger, :date => 6.days.ago, :amount => BigDecimal.new("100")) }
    let!(:debit_2) { FactoryGirl.create(:debit, :ledger => ledger, :date => 4.days.ago, :amount => BigDecimal.new("10")) }
    let!(:debit_3) { FactoryGirl.create(:debit, :ledger => ledger, :date => 2.days.ago, :amount => BigDecimal.new("50")) }
    let!(:credit_1) { FactoryGirl.create(:credit, :ledger => ledger, :date => 5.days.ago, :amount => BigDecimal.new("120")) }
    let!(:credit_2) { FactoryGirl.create(:credit, :ledger => ledger, :date => 4.day.ago, :amount => BigDecimal.new("10")) }

    before(:each) do
      ledger.do_accounting!
      delete_first_entry
    end

    def add_debit(date = 1.day.ago, amount = BigDecimal.new("0"))
      debit = FactoryGirl.create(:debit, :ledger => ledger, :date => date, :amount => amount)
    end
  
    def add_credit(date = 1.day.ago, amount = BigDecimal.new("0"))
      credit = FactoryGirl.create(:credit, :ledger => ledger, :date => date, :amount => amount)
    end

    def delete_first_entry
      entry = ledger.debits.first.entries.first
      entry.destroy unless entry.nil?
      return true
    end
  end
end