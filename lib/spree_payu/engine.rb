module SpreePayu
  class Engine < Rails::Engine
    require 'spree/core'
    require 'deface'
    engine_name 'spree_payu'

    isolate_namespace SpreePayuGateway

    config.autoload_paths += %W[#{config.root}/lib]

    config.after_initialize do |app|
      app.config.spree.payment_methods << Spree::Gateway::Payu
    end

    def self.activate
      # if self.frontend_available?
      #   Dir.glob(File.join(File.dirname(__FILE__), '../../app/overrides/*.rb')) do |c|
      #     Rails.application.config.cache_classes ? require(c) : load(c)
      #   end
      # end

      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    def self.frontend_available?
      @@frontend_available ||= ::Rails::Engine.subclasses.map(&:instance).map{ |e| e.class.to_s }.include?('Spree::Frontend::Engine')
    end

    config.to_prepare &method(:activate).to_proc
  end

end
