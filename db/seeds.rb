# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Company.destroy_all

puts "Creating example companies..."

companies_data = [
  { name: 'Beequip B.V.', coc_number: '68727720', city: 'Amsterdam', address: 'Spuistraat 104A' },
  { name: 'ABC Transport', coc_number: '12345678', city: 'Rotterdam', address: 'Coolsingel 100' },
  { name: 'XYZ Solutions', coc_number: '87654321', city: 'Utrecht', address: 'Domplein 1' },
  { name: 'Tech Innovations BV', coc_number: '11223344', city: 'Amsterdam', address: 'Herengracht 200' },
  { name: 'Green Energy Corp', coc_number: '99887766', city: 'Eindhoven', address: 'Stationsweg 50' },
  { name: 'Digital Services', coc_number: '55667788', city: 'Den Haag', address: 'Lange Voorhout 10' },
  { name: 'Food Distributors', coc_number: '44332211', city: 'Groningen', address: 'Grote Markt 5' },
  { name: 'Fashion House BV', coc_number: '33445566', city: 'Maastricht', address: 'Vrijthof 20' },
  { name: 'Construction Co.', coc_number: '22334455', city: 'Arnhem', address: 'Rijnkade 45' },
  { name: 'Media Group', coc_number: '66778899', city: 'Breda', address: 'Grote Markt 30' },
  { name: 'Software Development BV', coc_number: '10101010', city: 'Amsterdam', address: 'Dam 1' },
  { name: 'Consulting Experts', coc_number: '20202020', city: 'Rotterdam', address: 'Blaak 50' },
  { name: 'Marketing Solutions', coc_number: '30303030', city: 'Utrecht', address: 'Oudegracht 100' },
  { name: 'Healthcare Services', coc_number: '40404040', city: 'Amsterdam', address: 'Vijzelstraat 75' },
  { name: 'Legal Advisors BV', coc_number: '50505050', city: 'Den Haag', address: 'Plein 20' }
]

companies_data.each do |company_data|
  Company.create!(company_data)
  print "."
end

puts "\n\n✅ #{Company.count} companies successfully created!"
puts "\nYou can:"
puts "  - Access the search in: http://localhost:3000"
puts "  - Access the admin at: http://localhost:3000/admin/companies"
puts "  - Import more companies via CSV using the file: config/data/companies.csv"
