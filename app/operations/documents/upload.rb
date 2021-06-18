# frozen_string_literal: true

module Documents
  # Uploads documents to doc storage via cartafact
  class Upload
    send(:include, Dry::Monads[:result, :do, :try])

    def call(resource_id:, file:, user_id:, subjects: nil)
      _validate = yield validate(resource_id, file)
      header = yield construct_headers(resource_id, user_id)
      body = yield construct_body(resource_id, file, subjects)
      response = yield upload_to_doc_storage(resource_id, header, body)
      validated_response = yield validate_response(response.transform_keys(&:to_sym))
      Success(validated_response)
    end

    private

    def validate(resource_id, file)
      return Failure({ :message => ['Resource id is nil'] }) if resource_id.nil?
      return Failure({ :message => ['File to upload is missing'] }) if file.nil?

      Success(true)
    end

    def encoded_payload(payload)
      Base64.strict_encode64(payload.to_json)
    end

    def fetch_file(file)
      file.tempfile
    end

    def fetch_secret_key
      Rails.application.secrets.secret_key_base
    end

    def fetch_url
      Rails.application.config.cartafact_document_base_url
    end

    def construct_headers(resource_id, user_id)
      payload_to_encode = {
        authorized_identity: { user_id: user_id.to_s, system: 'polypress' },
        authorized_subjects: [{ type: "notice", id: resource_id.to_s }]
      }

      Success(
        {
          'X-REQUESTINGIDENTITY' => encoded_payload(payload_to_encode),
          'X-REQUESTINGIDENTITYSIGNATURE' => Base64.strict_encode64(
            OpenSSL::HMAC.digest(
              "SHA256",
              fetch_secret_key,
              encoded_payload(payload_to_encode)
            )
          )
        }
      )
    end

    def construct_body(resource_id, file, subjects)
      document_body = {
        subjects: [{ id: resource_id.to_s, type: nil }],
        document_type: 'notice',
        creator: Settings.site.publisher,
        publisher: Settings.site.publisher,
        type: 'text',
        source: 'polypress',
        language: 'en',
        date_submitted: Time.now,
        title: File.basename(file),
        format: 'application/pdf'
      }
      document_body[:subjects] = subjects unless subjects.nil?

      Success(
        {
          document: document_body.to_json,
          content: file
        }
      )
    end

    def upload_to_doc_storage(resource_id, header, body)
      if Rails.env.production?
        response = HTTParty.post(fetch_url, :body => body, :headers => header)

        (response["errors"] || response["error"]).present? ? Failure({ :message => ['Unable to upload document'] }) : Success(response)
      else
        Success(test_env_response(resource_id))
      end
    end

    def validate_response(params)
      result = ::Contracts::Documents::UploadContract.new.call(params)

      result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
    end

    def test_env_response(resource_id)
      {
        :title => 'untitled',
        :language => 'en',
        :format => 'application/octet-stream',
        :source => 'polypress',
        :document_type => 'notice',
        :subjects => [{ :id => resource_id.to_s, :type => nil }],
        :id => BSON::ObjectId.new.to_s,
        :extension => 'pdf'
      }
    end
  end
end
