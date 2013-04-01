PSTN_DATA = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'support/operator_examples.yaml')) || {}

def with_operators(&block)
  number_assertions = {}
  PSTN_DATA.each do |country_id, country_data|
    default_assertions = {"country_id" => country_id}
    country_data["operators"].each do |operator, operator_data|
      default_assertions.merge!("id" => operator).merge!(operator_data["assertions"])
      operator_data["area_code_prefixes"].each do |area_code_prefix|
        country_data["area_codes"].each do |area_code, area|
          number_assertions[country_data["prefix"] + area_code + area_code_prefix + ("0" * (6 - area_code_prefix.length))] = default_assertions.merge(
            "area" => area, "area_code" => area_code, "prefix" => area_code_prefix
          )
        end
      end
      operator_data["prefixes"].each do |prefix|
        number_assertions[country_data["prefix"] + prefix + ("0" * 6)] = default_assertions.merge(
          "prefix" => prefix
        )
      end
    end
  end
  number_assertions.each do |sample_number, assertions|
    yield sample_number, assertions
  end
end
