require 'spec_helper'

describe GrapeSwagger::Representable do
  it 'has a version number' do
    expect(GrapeSwagger::Representable::VERSION).not_to be nil
  end

  it 'parser should be registred' do
    expect(GrapeSwagger.model_parsers[GrapeSwagger::Representable::Parser]).to eq('Representable::Decorator')
  end
end
