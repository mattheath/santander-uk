#!/usr/bin/env ruby

require "mechanize"

agent = Mechanize.new

# Add additional questions and answers
qa = {
  "Name of first school" => "",
  "Mother's middle name" => "",
  "Place of Birth" => "",
}

# Login Page 1
page = agent.get('https://retail.santander.co.uk/LOGSUK_NS_ENS/BtoChannelDriver.ssobto?dse_operationName=LOGON')
login_form = page.form('formCustomerID_1')
login_form.field_with(:id => "infoLDAP_E.customerID").value = ""  # Enter account ID
page = agent.submit(login_form, login_form.buttons.first)

# Login Page 2 is optional, only displayed if client is not 'recognised'
if (login_form = page.form(:id => 'formCustomerID'))
  question = page.search('#formCustomerID').search('.form-item').first.search('span.data').text.strip
  login_form.field_with(:id => "cbQuestionChallenge.responseUser").value = qa[question]
  page = agent.submit(login_form, login_form.buttons[1])
end

# Login Page 3
login_form = page.form(:id => 'formAuthenticationAbbey')
login_form.field_with(:id => "authentication.PassCode").value = ""  # Enter Passcode
login_form.field_with(:id => "authentication.ERN").value = ""  # Enter 5 digit number
page = agent.submit(login_form, login_form.buttons[1])

# Now at home page!
pp page
current_balance = page.search('table.myAccounts').search('tr').search('td')[1].text
available_balance = page.search('table.myAccounts').search('tr').search('td')[2].text

puts "current balance: #{current_balance}"

puts "available balance: #{available_balance}"
