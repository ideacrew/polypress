require "rails_helper"

RSpec.describe Config::SiteHelper, :type => :helper, dbclean: :after_each do

  describe "Site settings" do

    context '.site_name' do
      
      it 'should return application name' do
        expect(helper.site_name).to eq "enroll_me"
      end
    end
    
    context '.medicaid_agency_name' do
      
      it 'should return medicaid agency name' do
        expect(helper.medicaid_agency_name).to eq "Office for Family Independence"
      end
    end

    context '.medicaid_agency_phone' do

      it 'should return medicaid agency phone' do 
        expect(helper.medicaid_agency_phone).to eq "(855) 797-4357"
      end
    end

    context '.contact_center_short_phone_number' do

      it 'should return contact center short phone number' do
        expect(helper.contact_center_short_phone_number).to eq "(800) 965-7476"
      end
    end

    context '.marketplace_shopping_name' do

      it 'should return shopping name' do
        expect(helper.marketplace_shopping_name).to eq "Plan Compare"
      end
    end
  end
end
