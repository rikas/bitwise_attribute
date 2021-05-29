# frozen_string_literal: true

RSpec.describe BitwiseAttribute do
  describe '.attr_bitwise' do
    context 'when adding a new attr_bitwise' do
      let(:test_class) do
        Class.new do
          include BitwiseAttribute
          attr_accessor :country_mask
        end
      end

      let(:keys) { %i[pt fr br es] }
      let(:instance) { test_class.new }

      it 'creates a boolean helper method for each key' do
        test_class.attr_bitwise :countries, values: keys

        keys.each { |key| expect(instance).to respond_to("#{key}?") }
      end

      it 'returns a value for the helper methods' do
        test_class.attr_bitwise :countries, values: keys

        keys.each { |key| expect(instance.send("#{key}?")).not_to be_nil }
      end
    end
  end

  context 'with a valid mapping' do
    let(:model) do
      Class.new do
        include BitwiseAttribute

        attr_accessor :country_mask, :roles_number

        attr_bitwise :countries, values: %i[pt fr en gb kr cn]
        attr_bitwise :roles, column_name: :roles_number, values: %i[user moderator admin]

        def initialize
          @country_mask = 0
          @roles_number = 0
        end
      end
    end

    let(:record) { model.new }

    describe '.<name>' do
      it 'returns the defined mappings with no column name' do
        expect(model.countries).to eq(pt: 1, fr: 2, en: 4, gb: 8, kr: 16, cn: 32)
      end

      it 'returns the defined mappings with column name' do
        expect(model.roles).to eq(user: 1, moderator: 2, admin: 4)
      end
    end

    describe '#<name>' do
      it 'returns the list of values' do
        record.country_mask = 12

        expect(record.countries).to contain_exactly(:gb, :en)
      end

      it 'returns the list correctly when using column name' do
        record.roles_number = 7

        expect(record.roles).to contain_exactly(:user, :moderator, :admin)
      end
    end

    describe '#<name>=' do
      it 'sets the model values' do
        record.countries = %i[cn en]

        expect(record.countries).to contain_exactly(:cn, :en)
      end

      it 'changes the underlying column value' do
        record.countries = %i[cn en]

        expect(record.country_mask).to eq(36)
      end

      it 'changes the value correctly' do
        record.roles = %i[user admin]

        expect(record.roles_number).to eq(5)
      end

      it 'removes invalid keys' do
        record.countries = ['', 'cn', 'ilegal']

        expect(record.country_mask).to eq(32)
      end
    end

    describe 'values operations' do
      it 'merges values with "<<"' do
        record.roles = %i[user]
        record.roles << :moderator

        expect(record.roles).to contain_exactly(:user, :moderator)
      end

      it 'merges values with "+="' do
        record.countries = %i[fr]
        record.countries += %i[cn kr]

        expect(record.countries).to contain_exactly(:fr, :kr, :cn)
      end

      it 'removes values with "-="' do
        record.countries = %i[fr pt en]
        record.countries -= %i[pt]

        expect(record.countries).to contain_exactly(:fr, :en)
      end
    end
  end
end
