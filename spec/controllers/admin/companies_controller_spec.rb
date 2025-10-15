require 'rails_helper'

RSpec.describe Admin::CompaniesController, type: :controller do
  describe 'GET #index' do
    it 'assigns companies count' do
      Company.create!(name: 'Test', coc_number: '12345678', city: 'Amsterdam')
      get :index
      expect(assigns(:companies_count)).to eq(1)
    end

    it 'renders index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #import' do
    let(:csv_content) do
      <<~CSV
        name,coc_number,city,address
        Company A,12345678,Amsterdam,Street 1
      CSV
    end

    let(:csv_file) do
      FileUtils.mkdir_p(Rails.root.join('spec/fixtures/files'))

      file_path = Rails.root.join('spec/fixtures/files/companies.csv')
      File.write(file_path, csv_content)

      fixture_file_upload('companies.csv', 'text/csv')
    end

    after do
      file_path = Rails.root.join('spec/fixtures/files/companies.csv')
      File.delete(file_path) if File.exist?(file_path)
    end

    context 'with valid CSV file' do
      it 'imports companies' do
        expect {
          post :import, params: { file: csv_file }
        }.to change(Company, :count).by(1)
      end

      it 'redirects to index with success message' do
        post :import, params: { file: csv_file }
        expect(response).to redirect_to(admin_companies_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'without file' do
      it 'redirects with alert' do
        post :import
        expect(response).to redirect_to(admin_companies_path)
        expect(flash[:alert]).to match(/Please select a CSV file./)
      end
    end
  end

  describe 'DELETE #destroy_all' do
    before do
      Company.create!(name: 'Test', coc_number: '12345678', city: 'Amsterdam')
    end

    it 'deletes all companies' do
      expect {
        delete :destroy_all
      }.to change(Company, :count).to(0)
    end

    it 'redirects to index with notice' do
      delete :destroy_all
      expect(response).to redirect_to(admin_companies_path)
      expect(flash[:notice]).to be_present
    end
  end
end
