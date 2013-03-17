if Rails.env.development?
  # Pre-loaded our STI subclasses

  # Products
  %w[tire].each do |product|
    require_dependency File.join("app","models/applications/products","#{product}.rb")
  end

  # Credits & Debits
  %w[credda_credit credit_card_payment].each do |credit|
    require_dependency File.join("app","models/contracts/credits","#{credit}.rb")
  end

  %w[fee].each do |debit|
    require_dependency File.join("app","models/contracts/debits","#{debit}.rb")
  end

  # Ledgers
  %w[fifo_ledger].each do |ledger|
    require_dependency File.join("app","models/contracts/ledgers","#{ledger}.rb")
  end

end