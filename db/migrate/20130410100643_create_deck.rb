class CreateDeck < ActiveRecord::Migration
  def up
    create_table :decks do |t|
      t.text :cards
      t.integer :game_id
      t.timestamps
    end
  end

  def down
    drop_table :decks
  end
end
