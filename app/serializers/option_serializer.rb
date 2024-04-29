class OptionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :option_name
end