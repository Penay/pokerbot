class CreateGames < ActiveRecord::Migration
  def up
    create_table :games do |t|
      t.integer :user_id
    	t.integer :pot, :default => 0
      t.integer :blind, :default => 0
      t.integer :aggressive_bank, :default => 0
      t.integer :carefull_bank, :default => 0
      t.integer :aggressive_wins, :default => 0
      t.integer :carefull_wins, :default => 0
      t.integer :aggressive_losts, :default => 0
      t.integer :carefull_losts, :default => 0
      t.string :bot_type
    	t.string :name
      t.string :status, :default => "pending"
      t.boolean :player_turn, :default => false
      t.boolean :bot_turn, :default => false
      t.boolean :waiting, :default => false
      t.boolean :started, :default => false
      t.boolean :flop, :default => false
      t.boolean :turn, :default => false
      t.boolean :river, :default => false
      t.boolean :ended, :default => false
      t.timestamps
    end
  end

  def down
    drop_table :games
  end
end
