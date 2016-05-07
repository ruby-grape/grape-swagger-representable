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

GrapeSwagger.model_parsers.register(::GrapeSwagger::Representable::Parser, ::Representable::Decorator)
