class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.string :title
      t.text :summary
      t.date :date
      t.string :url

      t.timestamps
    end
  end
end
