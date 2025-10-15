require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    before do
      Company.create!(name: 'Existing Company', coc_number: '12345678', city: 'Amsterdam')
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:coc_number) }
    it { is_expected.to validate_presence_of(:city) }

    it 'validates uniqueness of coc_number' do
      duplicate_company = Company.new(name: 'New Company', coc_number: '12345678', city: 'Rotterdam')
      expect(duplicate_company).not_to be_valid
      expect(duplicate_company.errors[:coc_number]).to include('has already been taken')
    end
  end

  describe '.search' do
    let!(:company1) { Company.create!(name: 'Beequip BV', coc_number: '12345678', city: 'Amsterdam') }
    let!(:company2) { Company.create!(name: 'Tech Solutions', coc_number: '87654321', city: 'Rotterdam') }
    let!(:company3) { Company.create!(name: 'Amsterdam Services', coc_number: '11111111', city: 'Utrecht') }

    context 'when searching by name' do
      it 'finds companies with partial name match' do
        results = Company.search('Bee')
        expect(results).to include(company1)
        expect(results).not_to include(company2)
      end

      it 'is case insensitive' do
        results = Company.search('beequip')
        expect(results).to include(company1)
      end
    end

    context 'when searching by city' do
      it 'finds companies in specified city' do
        results = Company.search('Amsterdam')
        expect(results).to include(company1, company3)
        expect(results).not_to include(company2)
      end
    end

    context 'when searching by coc_number' do
      it 'finds company with matching coc_number' do
        results = Company.search('12345')
        expect(results).to include(company1)
      end
    end

    context 'when query is blank' do
      it 'returns empty relation' do
        expect(Company.search('')).to be_empty
        expect(Company.search(nil)).to be_empty
      end
    end

    context 'when multiple fields match' do
      it 'returns all matching companies' do
        results = Company.search('Amsterdam')
        expect(results.size).to eq(2)
      end
    end
  end

  describe '.import_from_csv' do
    context 'with comma-separated CSV' do
      let(:csv_content) do
        <<~CSV
          name,coc_number,city,address
          Company A,12345678,Amsterdam,Street 1
          Company B,87654321,Rotterdam,Street 2
          Company A Updated,12345678,Utrecht,Street 3
        CSV
      end

      let(:csv_file) do
        file = Tempfile.new(['companies', '.csv'])
        file.write(csv_content)
        file.rewind
        file
      end

      after do
        csv_file.close
        csv_file.unlink
      end

      it 'imports companies from CSV' do
        expect {
          Company.import_from_csv(csv_file)
        }.to change(Company, :count).by(2)
      end

      it 'updates existing companies with same coc_number' do
        result = Company.import_from_csv(csv_file)

        company = Company.find_by(coc_number: '12345678')
        expect(company.name).to eq('Company A Updated')
        expect(company.city).to eq('Utrecht')
      end

      it 'returns import statistics' do
        result = Company.import_from_csv(csv_file)

        expect(result[:count]).to eq(3)
        expect(result[:errors]).to be_empty
      end
    end

    context 'with semicolon-separated CSV' do
      let(:semicolon_csv_content) do
        <<~CSV
          coc_number;company_name;city
          12345678;Company A;Amsterdam
          87654321;Company B;Rotterdam
        CSV
      end

      let(:semicolon_csv_file) do
        file = Tempfile.new(['companies_semicolon', '.csv'])
        file.write(semicolon_csv_content)
        file.rewind
        file
      end

      after do
        semicolon_csv_file.close
        semicolon_csv_file.unlink
      end

      it 'imports companies from semicolon CSV' do
        expect {
          Company.import_from_csv(semicolon_csv_file)
        }.to change(Company, :count).by(2)
      end

      it 'correctly parses semicolon-separated data' do
        Company.import_from_csv(semicolon_csv_file)

        company = Company.find_by(coc_number: '12345678')
        expect(company.name).to eq('Company A')
        expect(company.city).to eq('Amsterdam')
      end
    end

    context 'with invalid data' do
      let(:invalid_csv_content) do
        <<~CSV
          name,coc_number,city,address
          ,12345678,Amsterdam,Street 1
        CSV
      end

      let(:invalid_csv_file) do
        file = Tempfile.new(['invalid', '.csv'])
        file.write(invalid_csv_content)
        file.rewind
        file
      end

      after do
        invalid_csv_file.close
        invalid_csv_file.unlink
      end

      it 'collects errors for invalid rows' do
        result = Company.import_from_csv(invalid_csv_file)
        expect(result[:errors]).not_to be_empty
      end
    end

    context 'with blank lines' do
      let(:csv_with_blanks) do
        <<~CSV
          name,coc_number,city
          Company A,12345678,Amsterdam

          Company B,87654321,Rotterdam
        CSV
      end

      let(:blank_csv_file) do
        file = Tempfile.new(['blanks', '.csv'])
        file.write(csv_with_blanks)
        file.rewind
        file
      end

      after do
        blank_csv_file.close
        blank_csv_file.unlink
      end

      it 'skips blank lines' do
        result = Company.import_from_csv(blank_csv_file)
        expect(result[:count]).to eq(2)
      end
    end
  end

  describe '.detect_csv_separator' do
    it 'detects comma as separator' do
      file = Tempfile.new(['comma', '.csv'])
      file.write("name,city,coc_number\n")
      file.rewind

      expect(Company.detect_csv_separator(file.path)).to eq(',')

      file.close
      file.unlink
    end

    it 'detects semicolon as separator' do
      file = Tempfile.new(['semicolon', '.csv'])
      file.write("name;city;coc_number\n")
      file.rewind

      expect(Company.detect_csv_separator(file.path)).to eq(';')

      file.close
      file.unlink
    end
  end
end
