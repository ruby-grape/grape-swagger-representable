# frozen_string_literal: true

module ThisInlineApi
  module Representers
    class Kind < Representable::Decorator
      include Representable::JSON

      property :id, documentation: { type: Integer, desc: 'Title of the kind.', example: 123 }
    end

    class Tag < Representable::Decorator
      include Representable::JSON

      property :name, documentation: { type: 'string', desc: 'Name', example: -> { 'A tag' } }
    end

    class Error < Representable::Decorator
      include Representable::JSON

      property :code, default: 403, documentation: { type: 'string', desc: 'Error code' }
      property :message, documentation: { type: 'string', desc: 'Error message' }
    end

    class Something < Representable::Decorator
      include Representable::JSON

      property :text, documentation: { type: 'string', desc: 'Content of something.' }
      property :original, as: :alias, documentation: { type: 'string', desc: 'Aliased.' }
      property :kind, decorator: Kind, documentation: { desc: 'The kind of this something.' }
      property :kind2, decorator: Kind, documentation: { desc: 'Secondary kind.' } do
        property :name, documentation: { type: String, desc: 'Kind name.' }
      end
      property :kind3, decorator: ThisInlineApi::Representers::Kind, documentation: { desc: 'Tertiary kind.' }
      property :kind4, decorator: ThisInlineApi::Representers::Kind, documentation: { required: true } do
        property :id, documentation: { required: true }
      end
      collection :tags, decorator: ThisInlineApi::Representers::Tag, documentation: { desc: 'Tags.' } do
        property :color, documentation: { type: String, desc: 'Tag color.', values: -> { %w[red blue green] }, default: 'red' }
      end
    end
  end

  class ResponseModelApi < Grape::API
    format :json
    desc 'This returns something',
         is_array: true,
         http_codes: [{ code: 200, message: 'OK', model: Representers::Something }]
    get '/something' do
      something = Struct.new('Something', :text).new('something')
      Representers::Something.new(something).to_hash
    end

    # something like an index action
    desc 'This returns something',
         entity: Representers::Something,
         http_codes: [
           { code: 200, message: 'OK', model: Representers::Something },
           { code: 403, message: 'Refused to return something', model: Representers::Error }
         ]
    params do
      optional :id, type: Integer
    end
    get '/something/:id' do
      if params[:id] == 1
        something = Struct.new('Something', :text).new('something')
        Representers::Something.new(something).to_hash
      else
        error = Struct.new('SomeError', :code, :message).new('some_error', 'Some error')
        Representers::Error.new(error).to_hash
      end
    end

    add_swagger_documentation
  end
end

describe 'responseInlineModel' do
  def app
    ThisInlineApi::ResponseModelApi
  end

  subject do
    get '/swagger_doc/something'
    JSON.parse(last_response.body)
  end

  it 'documents index action' do
    expect(subject['paths']['/something']['get']['responses']).to eq(
      '200' => {
        'description' => 'OK',
        'schema' => {
          'type' => 'array',
          'items' => { '$ref' => '#/definitions/ThisInlineApi_Representers_Something' }
        }
      }
    )
  end

  it 'should document specified models as show action' do
    expect(subject['paths']['/something/{id}']['get']['responses']).to eq(
      '200' => {
        'description' => 'OK',
        'schema' => { '$ref' => '#/definitions/ThisInlineApi_Representers_Something' }
      },
      '403' => {
        'description' => 'Refused to return something',
        'schema' => { '$ref' => '#/definitions/ThisInlineApi_Representers_Error' }
      }
    )
    expect(subject['definitions'].keys).to include 'ThisInlineApi_Representers_Error'
    expect(subject['definitions']['ThisInlineApi_Representers_Error']).to eq(
      'type' => 'object',
      'description' => 'ThisInlineApi_Representers_Error model',
      'properties' => {
        'code' => { 'type' => 'string', 'description' => 'Error code', 'default' => 403 },
        'message' => { 'type' => 'string', 'description' => 'Error message' }
      }
    )

    expect(subject['definitions'].keys).to include 'ThisInlineApi_Representers_Something'
    expect(subject['definitions']['ThisInlineApi_Representers_Something']).to eq(
      'type' => 'object',
      'description' => 'ThisInlineApi_Representers_Something model',
      'properties' => {
        'text' => { 'description' => 'Content of something.', 'type' => 'string' },
        'alias' => { 'description' => 'Aliased.', 'type' => 'string' },
        'kind' => {
          '$ref' => '#/definitions/ThisInlineApi_Representers_Kind',
          'description' => 'The kind of this something.'
        },
        'kind2' => {
          'type' => 'object',
          'properties' => {
            'id' => {
              'description' => 'Title of the kind.',
              'type' => 'integer',
              'format' => 'int32',
              'example' => 123
            },
            'name' => { 'description' => 'Kind name.', 'type' => 'string' }
          },
          'description' => 'Secondary kind.'
        },
        'kind3' => {
          '$ref' => '#/definitions/ThisInlineApi_Representers_Kind',
          'description' => 'Tertiary kind.'
        },
        'kind4' => {
          'description' => '',
          'properties' => {
            'id' => {
              'description' => '',
              'example' => 123,
              'format' => 'int32',
              'type' => 'string'
            }
          },
          'required' => ['id'],
          'type' => 'object'
        },
        'tags' => {
          'type' => 'array',
          'items' => {
            'type' => 'object',
            'properties' => {
              'name' => { 'description' => 'Name', 'type' => 'string', 'example' => 'A tag' },
              'color' => {
                'description' => 'Tag color.',
                'type' => 'string',
                'enum' => %w[red blue green],
                'default' => 'red'
              }
            }
          },
          'description' => 'Tags.'
        }
      },
      'required' => ['kind4']
    )

    expect(subject['definitions'].keys).to include 'ThisInlineApi_Representers_Kind'
    expect(subject['definitions']['ThisInlineApi_Representers_Kind']).to eq(
      'type' => 'object',
      'properties' => {
        'id' => {
          'description' => 'Title of the kind.',
          'type' => 'integer',
          'format' => 'int32',
          'example' => 123
        }
      }
    )
  end
end
