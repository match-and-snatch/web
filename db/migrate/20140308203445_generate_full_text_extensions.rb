class GenerateFullTextExtensions < ActiveRecord::Migration
  def change
    execute "create extension fuzzystrmatch;"
    execute "create extension unaccent;"
    execute "create extension pg_trgm;"
  end
end
