class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string :key, :length => 255, :null => false
      t.string :value_type, :length => 255, :null => false
      t.text :value
      t.text :default_value, :null => false
    end
    add_index :settings, :key, :unique => true
  end

  def self.down
    drop_table :settings
  end
end
