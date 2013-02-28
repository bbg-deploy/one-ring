class PrivacyPdf < Prawn::Document
  def initialize
    super()

    header
    intro
    information_we_collect
#    thanks_message
#    subscription_date
#    subscription_details
#    subscription_amount
#    regards_message
  end

  def header
    logopath =  "#{Rails.root}/app/assets/images/logo-color.png"
    image logopath, :width => 150
    move_down 15
    text "Privacy Policy", :size => 14
    text "March 13, 2012", :size => 14
  end
  
  def intro
    text "Credda values your privacy and is committed to ensuring your personal information is kept secure and is only used to help Credda conduct its business.  This notice describes our privacy policy.", :size => 12
  end

  def information_we_collect
    font_size 10
    
    text "Information We Collect", :size => 14
    text "Website usage information we collect", :size => 12
    text "\u2022 We may collect IP addresses, access times, browser types and browser languages."
    text "\u2022 We use both session and permanent cookies, which are small data files stored in your computer or device memory."
    text "\u2022 Credda collects this website usage information in order to improve our website's ease of use recognize you each time you visit our website collect statistics on your use of our website."
    
    text "Personal information we collect", :size => 12
    text "\u2022 We collect your personal identifying information associated with obtaining credit bureau reports such as your name, address, social security number, phone number and date of birth."
    text "\u2022 We also collect your personal information from others, such as credit bureaus, affiliates, or other companies."
    text "\u2022 We collect your contact information such as phone numbers, email addresses and residence addresses."
    text "\u2022 We collect your employment related information."
    text "\u2022 We collect your bank account information.  We consider your bank account information as eligible for us to process payments against. In addition, as part of our information collection process, we may detect additional bank accounts under your ownership.  We will consider these additional accounts to be part of the application process."
    text "\u2022 We collect and store all transaction history on our customers."


=begin
    %h4 Credda collects this personal information in order to:
    %ul 
      %li provide users with a meaningful service,verify the identity of users of our services
      %li process your lease application
      %li service your lease agreement
      %li communicate with you regarding products or services you have with Credda
      %li alert you of new products or services, special offers and updated policies
      %li update our policies and procedures
=end          
  end

  def thanks_message
    move_down 80
    text "Hello #{@invoice.customer.profile.first_name.capitalize},"
    move_down 15
    text "Thank you for your order.Print this receipt as 
    confirmation of your order.",
    :indent_paragraphs => 40, :size => 13
  end

  def subscription_date
    move_down 40
    text "Subscription start date: 
    #{@invoice.start_date.strftime("%d/%m/%Y")} ", :size => 13
    move_down 20
    text "Subscription end date :  
    #{@invoice.end_date.strftime("%d/%m/%Y")}", :size => 13
  end

  def subscription_details
    move_down 40
    table subscription_item_rows, :width => 500 do
      row(0).font_style = :bold
      columns(1..3).align = :right
      self.header = true
      self.column_widths = {0 => 200, 1 => 100, 2 => 100, 3 => 100}
    end
  end

  def subscription_amount
    subscription_amount = @invoice.calculate_subscription_amount
    vat = @invoice.calculated_vat
    delivery_charges = @invoice.calculated_delivery_charges
    sales_tax =  @invoice.calculated_sales_tax
    table ([["Vat (12.5% of Amount)", "", "", "#{precision(vat)}"] ,
    ["Sales Tax (10.3% of half the Amount)", "", "",
    "#{precision(sales_tax)}"]   ,
    ["Delivery charges", "", "", "#{precision(delivery_charges)}  "],
    ["", "", "Total Amount", "#{precision(@invoice.total_amount) }  "]]), 
    :width => 500 do
      columns(2).align = :left
      columns(3).align = :right
      self.header = true
      self.column_widths = {0 => 200, 1 => 100, 2 => 100, 3 => 100}
      columns(2).font_style = :bold
    end
  end

  def subscription_item_rows
    [["Description", "Quantity", "Rate", "Amount"]] +
    @invoice.subscriptions.map do |subscribe|
      [ "#{subscribe.description} ", subscribe.quantity, 
      "#{precision(subscribe.rate)}  ",  
      "#{precision(subscribe.quantity  * subscribe.rate)}" ]
    end
  end

  def precision(num)
    @view.number_with_precision(num, :precision => 2)
  end

  def regards_message
    move_down 50
    text "Thank You," ,:indent_paragraphs => 400
    move_down 6
    text "XYZ",
    :indent_paragraphs => 370, :size => 14, style:  :bold
  end
end