# frozen_string_literal: true

require 'yaml'

# CreateNoticeKind
class CreateNoticeKind
  send(:include, Dry::Monads[:result, :do])

  # @param [Hash] "market_kind"=>"aca_individual", "notice_number"=>"new", "title"=>"new", "description"=>"new", "event_name"=>"new", "recipient"=>"MergeDataModels::ConsumerRole", "template"=>{"raw_body"=>""}
  # @return [NoticeKind] NoticeKind object will be returned
  def call(params)
    values = yield validate(params)
    notice_kind = yield create(values)

    Success(notice_kind)
  end

  private

  def validate(params)
    result = NoticeKinds::Contracts::NoticeKind.new.call(params)
    result.success? ? Success(result.to_h) : Failure(result)
  end

  def create(params)
    notice_kind = NoticeKind.new(params)
    Success(notice_kind)
  end
end
