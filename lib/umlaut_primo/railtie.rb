module UmlautPrimo
  class Railtie < Rails::Railtie
    initializer "umlaut_primo.initialize" do |app|
      require "require_all"
      require_all "#{File.dirname(__FILE__)}/../umlaut_primo/"
    end
  end
end
