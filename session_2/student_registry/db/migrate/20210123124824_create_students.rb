class CreateStudents < ActiveRecord::Migration[6.1]
  def change
    create_table :students do |t|
      t.string :name
      t.string :roll_number
      t.string :branch
      t.decimal :cgpa, precision: 4, scale: 2
      t.text :address
      t.integer :admission_year

      t.timestamps
    end
  end
end
