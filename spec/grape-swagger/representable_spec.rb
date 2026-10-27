# frozen_string_literal: true

describe GrapeSwagger::Representable do
  it 'has a version number' do
    expect(GrapeSwagger::Representable::VERSION).not_to be nil
  end

  it 'parser should be registred' do
    expect(GrapeSwagger.model_parsers.to_a).to include([GrapeSwagger::Representable::Parser, 'Representable::Decorator'])
  end
end
