require 'rails_helper'

RSpec.describe "Company Search", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:company1) { Company.create!(name: 'Beequip BV', coc_number: '12345678', city: 'Amsterdam') }
  let!(:company2) { Company.create!(name: 'Tech Solutions', coc_number: '87654321', city: 'Rotterdam') }

  describe "Search functionality" do
    it "displays search page on root" do
      visit root_path
      expect(page).to have_content('Company Search')
      expect(page).to have_field('query')
    end

    it "searches for companies by name" do
      visit root_path
      fill_in 'query', with: 'Beequip'
      click_button 'Search'

      expect(page).to have_content('Beequip BV')
      expect(page).to have_content('Amsterdam')
      expect(page).not_to have_content('Tech Solutions')
    end

    it "searches for companies by city" do
      visit root_path
      fill_in 'query', with: 'Rotterdam'
      click_button 'Search'

      expect(page).to have_content('Tech Solutions')
      expect(page).not_to have_content('Beequip BV')
    end

    it "searches for companies by CoC number" do
      visit root_path
      fill_in 'query', with: '12345'
      click_button 'Search'

      expect(page).to have_content('Beequip BV')
    end

    it "shows message when no results found" do
      visit root_path
      fill_in 'query', with: 'NonexistentCompany'
      click_button 'Search'

      expect(page).to have_content('No companies found')
    end

    it "shows all matching results" do
      Company.create!(name: 'Amsterdam Corp', coc_number: '11111111', city: 'Amsterdam')

      visit root_path
      fill_in 'query', with: 'Amsterdam'
      click_button 'Search'

      expect(page).to have_content('Beequip BV')
      expect(page).to have_content('Amsterdam Corp')
    end
  end

  describe "Navigation" do
    it "has link to admin area" do
      visit root_path
      expect(page).to have_link('Admin Area')
    end

    it "navigates to admin area" do
      visit root_path
      click_link 'Admin Area'
      expect(page).to have_content('Business Administration')
    end
  end
end
