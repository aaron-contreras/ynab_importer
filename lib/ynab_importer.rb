# frozen_string_literal: true

require_relative "ynab_importer/version"
require_relative "ynab_importer/importer"
require "dotenv/load"
require "ynab"

module YnabImporter
  class Error < StandardError; end
  # Your code goes here...
end
