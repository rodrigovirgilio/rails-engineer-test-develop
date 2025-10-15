class Company < ApplicationRecord
  validates :name, presence: true
  validates :coc_number, presence: true, uniqueness: true
  validates :city, presence: true

  def self.search(query)
    return none if query.blank?

    sanitized_query = sanitize_sql_like(query)
    pattern = "%#{sanitized_query}%"

    where(
      "LOWER(name) LIKE LOWER(?) OR LOWER(city) LIKE LOWER(?) OR coc_number LIKE ?",
      pattern, pattern, pattern
    ).order(:name)
  end

  def self.import_from_csv(file)
    require 'csv'

    companies_count = 0
    errors = []

    CSV.foreach(file.path,
                headers: true,
                header_converters: lambda { |h| h.strip.downcase.gsub(' ', '_').to_sym },
                col_sep: detect_csv_separator(file.path),
                skip_blanks: true) do |row|
      begin
        coc_number = row[:coc_number] || row[:cocnumber] || row[:coc] || row[:registry_number]
        name = row[:name] || row[:company_name] || row[:companyname]
        city = row[:city] || row[:cidade]
        address = row[:address] || row[:endereco] || row[:adres]

        next if coc_number.blank? && name.blank? && city.blank?

        company = find_or_initialize_by(coc_number: coc_number.to_s.strip)
        company.assign_attributes(
          name: name.to_s.strip,
          city: city.to_s.strip,
          address: address.to_s.strip
        )

        if company.save
          companies_count += 1
        else
          errors << "Line with CoC #{coc_number}: #{company.errors.full_messages.join(', ')}"
        end
      rescue => e
        errors << "Error processing line: #{e.message}"
      end
    end

    { count: companies_count, errors: errors }
  end

  def self.detect_csv_separator(file_path)
    first_line = File.open(file_path, &:readline).strip rescue ""

    comma_count = first_line.count(',')
    semicolon_count = first_line.count(';')

    semicolon_count > comma_count ? ';' : ','
  end
end
