module GrapeSwagger
  module Representable
    class Parser
      attr_reader :model
      attr_reader :endpoint

      def initialize(model, endpoint)
        @model = model
        @endpoint = endpoint
      end

      def call
        parse_representer(model)
      end

      private

      def parse_representer_property(property)
        is_a_collection = property.is_a?(::Representable::Hash::Binding::Collection)
        documentation = property[:documentation] ? property[:documentation].dup : {}

        if property[:decorator] && property[:nested]
          representer_mapping(property[:decorator], documentation, property, is_a_collection, false, property[:nested])
        elsif property[:decorator]
          representer_mapping(property[:decorator], documentation, property, is_a_collection, true)
        elsif property[:nested]
          representer_mapping(property[:nested], documentation, property, is_a_collection)
        else
          memo = {
            description: documentation[:desc] || property[:desc] || ''
          }

          data_type = GrapeSwagger::DocMethods::DataType.call(documentation[:type] || property[:type])
          if GrapeSwagger::DocMethods::DataType.primitive?(data_type)
            data = GrapeSwagger::DocMethods::DataType.mapping(data_type)
            memo[:type] = data.first
            memo[:format] = data.last
          else
            memo[:type] = data_type
          end

          values = documentation[:values] || property[:values] || nil
          memo[:enum] = values if values.is_a?(Array)

          example = documentation[:example] || property[:example] || nil
          memo[:example] = example.is_a?(Proc) ? example.call : example if example

          if is_a_collection || documentation[:is_array]
            memo = {
              type: :array,
              items: memo
            }
          end

          memo
        end
      end

      def representer_mapping(representer, documentation, property, is_a_collection = false, is_a_decorator = false, nested = nil)
        if nested.nil? && is_a_decorator
          name = endpoint.send(:expose_params_from_model, representer)

          if is_a_collection || documentation[:is_array]
            {
              type: :array,
              items: {
                '$ref' => "#/definitions/#{name}"
              },
              description: documentation[:desc] || property[:desc] || ''
            }
          else
            {
              '$ref' => "#/definitions/#{name}",
              description: documentation[:desc] || property[:desc] || ''
            }
          end
        else
          attributes = parse_representer(representer)
          attributes = attributes.deep_merge!(parse_representer(nested)) if nested

          if is_a_collection
            {
              type: :array,
              items: {
                type: :object,
                properties: attributes
              },
              description: documentation[:desc] || property[:desc] || ''
            }
          else
            {
              type: :object,
              properties: attributes,
              description: documentation[:desc] || property[:desc] || ''
            }
          end
        end
      end

      def parse_representer(representer)
        representer.map.each_with_object({}) do |value, property|
          property_name = value[:as].try(:call) || value.name
          property[property_name] = parse_representer_property(value)
        end
      end
    end
  end
end
