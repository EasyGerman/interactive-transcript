class CustomStruct < ::Dry::Struct
  transform_keys(&:to_sym)
end
