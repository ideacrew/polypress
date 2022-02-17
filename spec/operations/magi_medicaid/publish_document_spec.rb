# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/enrollments/family_response"
require "#{Rails.root}/spec/shared_examples/eligibilities/application_response"
require 'dry/monads'
require 'dry/monads/do'

RSpec.describe MagiMedicaid::PublishDocument do
  send(:include, Dry::Monads[:result, :do])

  describe 'with valid arguments' do
    include_context 'application response from medicaid gateway'

    let(:title) { 'Uqhp Document' }
    let(:event_key) { 'magi_medicaid.mitc.eligibilities.determined_uqhp_eligible' }
    let(:body) { '<p>Uqhp Eligible Document for {{ hbx_id }}</p>' }

    let!(:template) do
      FactoryBot.create(
        :template,
        key: event_key,
        body: {
          markup: body
        },
        title: title,
        print_code: 'IVLMWE',
        marketplace: 'aca_individual',
        recipient: 'AcaEntities::Families::Family',
        content_type: 'application/pdf',
        description: 'Uqhp Description',
        subscriber: EventRoutes::EventRouteModel.new(event_name: event_key)
      )
    end

    let(:entity) do
      ::AcaEntities::MagiMedicaid::Application.new(application_hash)
    end

    subject do
      described_class.new.call(
        entity: entity,
        template_model: template
      )
    end

    context 'when payload has all the required params' do
      before do
        Events::Documents::DocumentCreated
          .any_instance
          .stub(:publish)
          .and_return(true)
      end

      it 'should return success' do
        expect(subject.success?).to be_truthy
      end

      context 'when payload does not have primary member' do
        let(:non_primary_application_hash) do
          application_hash[:applicants][0].merge!(:is_primary_applicant => false)
          application_hash
        end
        let(:entity) do
          ::AcaEntities::MagiMedicaid::Application.new(non_primary_application_hash)
        end

        it 'should return success' do
          expect(subject.success?).to be_truthy
        end
      end
    end

    context 'when event key is invalid' do
      let(:invalid_subject) do
        described_class.new.call(
          entity: entity,
          event_key: invalid_event_key
        )
      end

      let(:invalid_event_key) { 'invalid_event_key' }

      let(:error) { 'Missing template model' }

      it 'should return failure' do
        expect(invalid_subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(invalid_subject.failure).to eq error
      end
    end

    context 'when template body has unknown attributes' do
      let(:body) do
        '<p>Uqhp Eligible Document for {{ unknown_attribute }}</p><p> {{ unknown_attribute_new }} </p> '
      end

      let(:error) do
        [
          'Liquid error (line 1): undefined variable unknown_attribute',
          'Liquid error (line 1): undefined variable unknown_attribute_new'
        ]
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.errors.map(&:to_s)).to eq error
      end
    end

    context 'when template body has syntax errors' do
      let(:body) { '<p>Uqhp Eligible Document for {% if %}</p>' }

      let(:error) do
        "Liquid syntax error (line 1): [:end_of_string] is not a valid expression in \"\""
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.to_s).to eq error
      end
    end

    describe 'move documents after upload' do
      let!(:document_name) do
        template.document_name_for(primary_applicant_hbx_id)
      end

      before do
        Events::Documents::DocumentCreated
          .any_instance
          .stub(:publish)
          .and_return(true)

        allow(template).to receive(:document_name_for)
          .with(primary_applicant_hbx_id)
          .and_return(document_name)
      end

      after do
        FileUtils.remove_dir(Rails.root.join('..', destination_folder)) if File.directory?(destination_folder)
      end

      context 'when a document uploaded successfully' do
        let(:destination_folder) do
          MagiMedicaid::PublishDocument::DOCUMENT_LOCAL_PATH
        end

        it 'should be moved document from tmp location to documents local path' do
          subject
          expect(Dir["#{Rails.root}/tmp/**/*.pdf"]).not_to include(
            Rails.root.join('tmp', "#{document_name}.pdf").to_s
          )
          destination_documents =
            Dir[Rails.root.join('..', destination_folder, '**', '*.pdf')]
            .map { |file| File.basename(file) }
          expect(destination_documents).to include("#{document_name}.pdf")
        end

        context 'when consumer opted for electronic communication only' do
          include_context 'family response from enroll'

          let(:primary_applicant_hbx_id) { family_member_1[:person][:hbx_id] }
          let(:contact_method) { 'Only Electronic communications' }
          let(:entity) { AcaEntities::Families::Family.new(family_hash.merge(magi_medicaid_applications: [application_hash])) }

          it 'should not move document to local path' do
            subject
            destination_documents =
              Dir[Rails.root.join('..', destination_folder, '**', '*.pdf')]
              .map { |file| File.basename(file) }
            expect(destination_documents).not_to include("#{document_name}.pdf")
          end
        end
      end

      context '#requires_paper_communication?' do

        let(:destination_folder) do
          MagiMedicaid::PublishDocument::DOCUMENT_LOCAL_PATH
        end

        let(:result) { ::MagiMedicaid::PublishDocument.new.send(:requires_paper_communication?, entity) }

        context 'when the entity is AcaEntities::Families::Family' do
          include_context 'family response from enroll'

          let(:entity) { AcaEntities::Families::Family.new(family_hash) }

          context 'when the consumer has contact method' do
            context 'when the contact method is paper' do
              let(:contact_method) { 'Paper, Electronic and Text Message communications' }
              it 'should return true' do
                expect(result).to be_truthy
              end
            end

            context 'when the contact method is electronic only' do
              let(:contact_method) { 'Electronic Only' }
              it 'should return false' do
                expect(result).to be_falsey
              end
            end
          end

          context 'when the contact method is not present' do
            it 'should return true' do
              expect(result).to be_truthy
            end
          end
        end

        context 'when the entity is AcaEntities::MagiMedicaid::Application' do

          context 'when paper_notification is true' do
            it 'should return true' do
              expect(result).to be_truthy
            end
          end

          context 'when paper_notification is false' do
            let(:paper_notification) { false }

            it 'should return false' do
              expect(result).to be_falsey
            end
          end
        end
      end

      context 'when a document uploaded failed' do
        let(:upload_instance) { Documents::Upload.new }
        let(:destination_folder) do
          MagiMedicaid::PublishDocument::DOCUMENT_LOCAL_ERROR_PATH
        end

        before do
          allow(upload_instance).to receive(:call).and_return(
            Failure('upload failed')
          )
          allow(Documents::Upload).to receive(:new).and_return(upload_instance)
        end

        it 'should be moved from tmp location to documents local errors path' do
          subject

          expect(Dir["#{Rails.root}/tmp/**/*.pdf"]).not_to include(
            Rails.root.join('tmp', "#{document_name}.pdf").to_s
          )
          destination_documents =
            Dir[Rails.root.join('..', destination_folder, '**', '*.pdf')]
            .map { |file| File.basename(file) }
          expect(destination_documents).to include("#{document_name}.pdf")
        end
      end
    end
  end
end
