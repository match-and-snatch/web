class GenerateFullTextExtensions < ActiveRecord::Migration
  def change
    begin
    execute "create extension fuzzystrmatch;"
    rescue
    end
    begin
    execute "create extension unaccent;"
    rescue
    end
    begin
    execute "create extension pg_trgm;"
    rescue
    end
  end
end
