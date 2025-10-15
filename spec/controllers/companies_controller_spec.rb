require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  describe 'GET #index' do
    let!(:company) { Company.create!(name: 'Test Company', coc_number: '12345678', city: 'Amsterdam') }

    context 'without query parameter' do
      it 'returns empty results' do
        get :index
        expect(assigns(:companies)).to be_empty
      end

      it 'renders index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'with query parameter' do
      it 'searches for companies' do
        get :index, params: { query: 'Test' }
        expect(assigns(:companies)).to include(company)
      end

      it 'assigns query variable' do
        get :index, params: { query: 'Test' }
        expect(assigns(:query)).to eq('Test')
      end

      it 'limits results to 50' do
        51.times do |i|
          Company.create!(name: "Company #{i}", coc_number: "#{i}0000000", city: 'Amsterdam')
        end

        get :index, params: { query: 'Company' }
        expect(assigns(:companies).size).to eq(50)
      end
    end

    context 'turbo_stream format' do
      it 'responds to turbo_stream format' do
        get :index, params: { query: 'Test' }, format: :turbo_stream
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end
  end
end
