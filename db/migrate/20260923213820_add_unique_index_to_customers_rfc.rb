class AddUniqueIndexToCustomersRfc < ActiveRecord::Migration[7.0]
  def change
    add_index :customers, :rfc, unique: true
  end
end