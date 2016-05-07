require 'grape-swagger'
require 'representable'

require 'grape-swagger/representable/version'
require 'grape-swagger/representable/parser'

module Grape
  module Swagger
    module Representable
    end
  end
end

GrapeSwagger.register_model_parser(::GrapeSwagger::Representable::Parser, ::Representable::Decorator)
