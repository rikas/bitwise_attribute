# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

# ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.integer :role_mask, default: 0
  end
end

class User < ActiveRecord::Base
  include BitwiseAttribute

  attr_bitwise :roles, values: %i[std mod a1 a2]
end

RSpec.describe BitwiseAttribute::ActiveRecordMethods do
  let!(:u1) { User.create!(roles: [:std]) }
  let!(:u2) { User.create!(roles: [:mod]) }
  let!(:u3) { User.create!(roles: [:a1]) }

  let!(:u4) { User.create!(roles: %i[std a1]) }
  let!(:u5) { User.create!(roles: %i[a1 mod std]) }
  let!(:u6) { User.create!(roles: %i[a1 a2 std]) }
  let!(:u7) { User.create!(roles: %i[std mod a1 a2]) }

  after { User.destroy_all }

  describe '.with_<name>' do
    it 'returns an empty array if no value is given' do
      expect(User.with_roles).to eq([])
    end

    it 'returns all records that have ALL values' do
      expect(User.with_roles(:std)).to contain_exactly(u1, u4, u5, u6, u7)
      expect(User.with_roles(:a2)).to contain_exactly(u6, u7)
      expect(User.with_roles(:std, :a1)).to contain_exactly(u4, u5, u6, u7)

      # It also accepts an array as the argument
      expect(User.with_roles(%i[std a1])).to contain_exactly(u4, u5, u6, u7)
    end
  end

  describe '.with_any_<name>' do
    it 'returns all records what have mask set' do
      expect(User.with_any_roles).to contain_exactly(u1, u2, u3, u4, u5, u6, u7)
    end

    it 'returns all records that have AT LEAST one of the values' do
      expect(User.with_any_roles(:std)).to contain_exactly(u1, u4, u5, u6, u7)
      expect(User.with_any_roles(:a2)).to contain_exactly(u6, u7)
      expect(User.with_any_roles(:std, :a1)).to contain_exactly(u1, u3, u4, u5, u6, u7)

      # It also accepts an array as the argument
      expect(User.with_any_roles(%i[std a1])).to contain_exactly(u1, u3, u4, u5, u6, u7)
    end
  end

  describe '.with_exact_<name>' do
    it 'returns an empty array if no value is given' do
      expect(User.with_exact_roles).to eq([])
    end

    it 'returns all records that have ALL values and nothing else' do
      expect(User.with_exact_roles(:std)).to contain_exactly(u1)
      expect(User.with_exact_roles(:a2)).to eq([])
      expect(User.with_exact_roles(:std, :a1)).to contain_exactly(u4)

      # It also accepts an array as the argument
      expect(User.with_exact_roles(%i[std a1])).to contain_exactly(u4)
    end
  end

  describe '.without_<name>' do
    it 'returns all records without mask set' do
      empty = User.create!(name: 'empty')

      expect(User.without_roles).to contain_exactly(empty)
    end

    it 'returns records that DO NOT have ALL values' do
      expect(User.without_roles(:std)).to contain_exactly(u2, u3)
      expect(User.without_roles(:a2)).to contain_exactly(u1, u2, u3, u4, u5)
      expect(User.without_roles(:std, :a1)).to contain_exactly(u2)

      # It also accepts an array as the argument
      expect(User.without_roles(%i[std a1])).to contain_exactly(u2)
    end
  end
end
