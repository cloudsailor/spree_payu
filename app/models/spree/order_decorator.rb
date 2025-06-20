# frozen_string_literal: true


module Spree
  module OrderDecorator
    def self.prepended(base)
      base.before_validation :added_prefix, on: %i[create update]
      base.before_save :update_completion_time
    end

    private

    def added_prefix
      return if number.present? && number.include?('NVS')

      self.number = ::Spree::Core::NumberGenerator.new(prefix: 'NVS').send(:generate_permalink, ::Spree::Order)
    end

    def update_completion_time
      max_completion_time = 0
      line_items&.each do |item|
        if item.variant && item.variant.public_metadata.present?
          completion_time = item.variant.public_metadata['days_completion_time'].to_i
          max_completion_time = completion_time if completion_time > max_completion_time
        end
      end

      return unless public_metadata['completion_time']&.to_i != max_completion_time

      existing_public_metadata = public_metadata || {}
      new_public_metadata = {
        completion_time: max_completion_time,
        completion_date: completion_date(max_completion_time)
      }
      update(public_metadata: existing_public_metadata.merge(new_public_metadata))
    end

    def completion_date(days_completion_time)
      url = URI("#{ENV['FULFILLMENT_URL']}/calculators/completion_time/#{days_completion_time}")
      response = JSON.parse(Net::HTTP.get(url))
      response['completion_date']
    end
  end
end


if ::Spree::Order.included_modules.exclude?(Spree::OrderDecorator)
  ::Spree::Order.prepend Spree::OrderDecorator
end
