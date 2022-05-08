require 'pry'
require 'ofx-parser'

module YnabImporter
  class Importer
    attr_reader :api

    def initialize(api:)
      @api = api
    end

    def call
      budget_response = api.budgets.get_budgets
      budgets = budget_response.data.budgets

      budget_id = budgets.first.id

      account_id = api.accounts.get_accounts(budget_id).data.accounts.find { |account| account.name == "BG" }.id


      resp = api.transactions.get_transactions_by_account(budget_id, account_id, since_date: Date.today.prev_month(2))

      last_imported_transaction_date = resp.data.transactions.sort_by { |t| t.date }.last.date

      ofx_client = OfxParser::OfxParser.parse(File.read('./ready_to_import/bg_0.ofx'))

      transactions_to_import = ofx_client.bank_account.statement.transactions.select { |t| t.date > last_imported_transaction_date }

      formatted_transactions = transactions_to_import.map do |t|
        {
          account_id: account_id,
          date: t.date.to_date,
          amount: (t.amount.to_f * 1000).to_i, # Convert to "milliunits"
          memo: t.memo
        } 
      end

      formatted_transactions = {
        transactions: formatted_transactions
      }


      resp = api.transactions.create_transaction(budget_id, formatted_transactions)

    end
  end
end