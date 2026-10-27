# frozen_string_literal: true

require 'grape-swagger'
require 'representable'

require_relative 'representable/version'
require_relative 'representable/parser'

module GrapeSwagger
  module Representable
  end
end

GrapeSwagger.model_parsers.register(GrapeSwagger::Representable::Parser, Representable::Decorator)
