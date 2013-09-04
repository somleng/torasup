module PstnHelpers
  include Torasup::Test::Helpers

  private

  def yaml_file(filename)
    File.join(File.dirname(__FILE__), "../../spec/support/#{filename}")
  end

  def configure_with_custom_data
    Torasup.configure do |config|
      config.custom_pstn_data_file = File.join(File.dirname(__FILE__), "../support", "/custom_pstn.yaml")
    end
  end
end
