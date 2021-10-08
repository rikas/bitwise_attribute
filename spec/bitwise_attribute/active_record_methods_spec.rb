# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

# Uncomment for debug
# ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.integer :role_mask, default: 0
  end
end

class User < ActiveRecord::Base
  include BitwiseAttribute

  attr_bitwise :roles, values: %i[std mod a1 a2 a3]
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
    context 'when no role is given' do
      it 'returns an empty array' do
        expect(User.with_roles).to eq([])
      end
    end

    context 'when one role is given' do
      it 'returns an empty array if no record matches' do
        expect(User.with_roles(:a3)).to eq([])
      end

      it 'returns the correct records for a value' do
        expect(User.with_roles(:a2)).to contain_exactly(u6, u7)
      end

      it 'returns all records that have ALL values' do
        expect(User.with_roles(:std)).to contain_exactly(u1, u4, u5, u6, u7)
      end

      it 'works properly with strings' do
        expect(User.with_roles('std')).to contain_exactly(u1, u4, u5, u6, u7)
      end
    end

    context 'when more than one argument is provided' do
      it 'returns the correct records for two values' do
        expect(User.with_roles(:std, :a1)).to contain_exactly(u4, u5, u6, u7)
      end

      it 'accepts an array as argument' do
        expect(User.with_roles(%i[std a1])).to contain_exactly(u4, u5, u6, u7)
      end

      it 'works properly with strings' do
        expect(User.with_roles(%w[std a1])).to contain_exactly(u4, u5, u6, u7)
      end
    end
  end

  describe '.with_any_<name>' do
    context 'when no role is given' do
      it 'returns all records that have mask set' do
        expect(User.with_any_roles).to contain_exactly(u1, u2, u3, u4, u5, u6, u7)
      end
    end

    context 'when one value is provided' do
      it 'returns an empty string if no record matches' do
        expect(User.with_any_roles(:a3)).to eq([])
      end

      it 'returns all records that have AT LEAST the value provided' do
        expect(User.with_any_roles(:std)).to contain_exactly(u1, u4, u5, u6, u7)
      end
    end

    context 'when multiple values are provided' do
      it 'returns all records that have AT LEAST the values provided' do
        expect(User.with_any_roles(:std, :a1)).to contain_exactly(u1, u3, u4, u5, u6, u7)
      end

      it 'accepts an array as argument' do
        expect(User.with_any_roles(%i[std a1])).to contain_exactly(u1, u3, u4, u5, u6, u7)
      end

      it 'works properly with strings' do
        expect(User.with_any_roles(%w[std a1])).to contain_exactly(u1, u3, u4, u5, u6, u7)
      end
    end
  end

  describe '.with_exact_<name>' do
    context 'when no role is given' do
      it 'returns an empty array' do
        expect(User.with_exact_roles).to eq([])
      end
    end

    context 'when one role is given' do
      it 'returns an empty array if no record matches' do
        expect(User.with_exact_roles(:a2)).to eq([])
      end

      it 'returns all records that have the value and nothing else' do
        expect(User.with_exact_roles(:std)).to contain_exactly(u1)
      end
    end

    context 'when more than one role is given' do
      it 'returns all records that have the values and nothing else' do
        expect(User.with_exact_roles(:std, :a1)).to contain_exactly(u4)
      end

      it 'accepts an array as argument' do
        expect(User.with_exact_roles(%i[std a1])).to contain_exactly(u4)
      end

      it 'works properly with strings' do
        expect(User.with_exact_roles(%w[std a1])).to contain_exactly(u4)
      end
    end
  end

  describe '.without_<name>' do
    context 'when no role is given' do
      let(:empty) { User.create!(name: 'empty') }

      it 'returns all records without mask set' do
        expect(User.without_roles).to contain_exactly(empty)
      end
    end

    context 'when one role is given' do
      it 'returns records that DO NOT have ALL values' do
        expect(User.without_roles(:std)).to contain_exactly(u2, u3)
      end

      it 'works with strings' do
        expect(User.without_roles('a2')).to contain_exactly(u1, u2, u3, u4, u5)
      end
    end

    context 'when more than one role is given' do
      it 'returns records that DO NOT have ALL values' do
        expect(User.without_roles(:std, :a1)).to contain_exactly(u2)
      end

      it 'accepts an array as argument' do
        expect(User.without_roles(%i[std a1])).to contain_exactly(u2)
      end

      it 'works properly with strings' do
        expect(User.without_roles(%w[std a1])).to contain_exactly(u2)
      end
    end
  end
end
