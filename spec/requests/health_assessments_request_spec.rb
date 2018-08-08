require 'rails_helper'

describe 'HealthAssessment Requests', type: :request do
  let!(:health_rating_type) { create(:health_rating_type, name: "good") }
  let!(:health_rating) { create(:health_rating, health_rating_type: health_rating_type) }
  let!(:default_health_assessment) { create(:default_health_assessment) }
  let!(:health_assessment) { create(:health_assessment, default_health_assessment: default_health_assessment, health_rating: health_rating) }

  before do
    sign_in(create(:user))
  end

  describe 'PUT update' do
    let(:health_assessment) { create(:health_assessment, default_health_assessment: default_health_assessment, rating: nil) }
    it 'updates the health_assessment amd sends a success flash message' do
      put "/health_assessments/#{health_assessment.id}",
          params: {
            target_id: target.id,
            health_assessment: {
              health_rating: 'good',
              name: 'new name'
            }
          }

      health_assessment.reload
      expect(health_assessment.health_rating.name).to eq 'good'
      expect(health_assessment.name).to eq 'new name'
      expect(flash[:notice]).to be_present
    end

    it 'does not update the health assessment and sends an error flash message when invalid params' do
      expect do
        put "/health_assessments/#{health_assessment.id}",
            params: {
              target_id: target.id,
              health_assessment: {
                rating: 'good',
                name: ''
              }
            }
      end.to_not change(health_assessment, :name)

      expect(flash[:alert]).to be_present
    end
  end

  describe 'POST create' do
    it 'creates a new health_assessment and sends a success flash message' do
      post '/health_assessments',
           params: {
             health_assessment: {
               name: 'new name'
             },
             target_id: target.id
           }

      health_assessment = HealthAssessment.last
      expect(health_assessment.target).to eq target
      expect(health_assessment.name).to eq 'new name'
      expect(flash[:notice]).to be_present
    end
    #
    # it 'does not create a health_assessment and sends an error flash message when invalid params' do
    #   expect do
    #     post '/health_assessments',
    #          params: {
    #            health_assessment: {
    #              name: ''
    #            },
    #            target_id: target.id
    #          }
    #   end.to_not change(HealthAssessment, :count)
    #
    #   expect(flash[:alert]).to be_present
    # end
  end

  describe 'DELETE destroy' do
    let(:health_assessment) { create(:health_assessment) }

    it 'deletes the health assessment and sends a success flash message' do
      deleted_id = health_assessment.id

      delete "/health_assessments/#{deleted_id}"

      expect(HealthAssessment.where(id: deleted_id)).to be_empty
      expect(flash[:notice]).to be_present
    end
  end
end