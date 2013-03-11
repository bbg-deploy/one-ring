if Rails.env.development?
  # Pre-loaded our STI subclasses
  %w[credda_credit credit_card_payment].each do |credit|
    require_dependency File.join("app","models/credits","#{credit}.rb")
  end

  %w[fee].each do |debit|
    require_dependency File.join("app","models/debits","#{debit}.rb")
  end

  %w[fifo_ledger].each do |ledger|
    require_dependency File.join("app","models/ledgers","#{ledger}.rb")
  end
end