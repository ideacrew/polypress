# frozen_string_literal: true

module Services
  # Responsible to provide tokens and recipients for a given market
  class NoticeKindService
    include Services::TokenBuilder

    attr_accessor :market_kind, :model_builder

    delegate :recipients, to: :service
    delegate :setting_placeholders, to: :service

    def initialize(market_kind)
      @market_kind = market_kind.to_sym
    end

    def builder=(builder_str)
      @model_builder = builder_str.constantize
    end

    def service
      if aca_individual?
        Services::IndividualNoticeService.new
      else
        Services::ShopNoticeService.new
      end
    end

    def aca_individual?
      market_kind == :aca_individual
    end
  end
end
