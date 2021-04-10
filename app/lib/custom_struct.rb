require 'memoist'

class CustomStruct < ::Dry::Struct
  extend Memoist
  transform_keys(&:to_sym)
end
