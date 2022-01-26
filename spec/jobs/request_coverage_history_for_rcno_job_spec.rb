# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestCoverageHistoryForRcnoJob, type: :job do
  describe "#perform_later" do
    it "enqueues an rcno report job" do
      ActiveJob::Base.queue_adapter = :test
      expect do
        RequestCoverageHistoryForRcnoJob.perform_later('12345')
      end.to have_enqueued_job
    end
  end
end
