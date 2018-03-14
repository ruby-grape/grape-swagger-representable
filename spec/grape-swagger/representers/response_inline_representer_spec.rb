require 'spec_helper'

describe 'responseInlineModel' do
  before :all do
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

          property :code, documentation: { type: 'string', desc: 'Error code' }
          property :message, documentation: { type: 'string', desc: 'Error message' }
        end

        class Something < Representable::Decorator
          include Representable::JSON

          property :text, documentation: { type: 'string', desc: 'Content of something.' }
          property :original, as: :alias, documentation: { type: 'string', desc: 'Aliased.'}
          property :kind, decorator: Kind, documentation: { desc: 'The kind of this something.' }
          property :kind2, decorator: Kind, documentation: { desc: 'Secondary kind.' } do
            property :name, documentation: { type: String, desc: 'Kind name.' }
          end
          property :kind3, decorator: ThisInlineApi::Representers::Kind, documentation: { desc: 'Tertiary kind.' }
          collection :tags, decorator: ThisInlineApi::Representers::Tag, documentation: { desc: 'Tags.' } do
            property :color, documentation: { type: String, desc: 'Tag color.' }
          end
        end
      end

      class ResponseModelApi < Grape::API
        format :json
        desc 'This returns something',
             is_array: true,
             http_codes: [{ code: 200, message: 'OK', model: Representers::Something }]
        get '/something' do
          something = OpenStruct.new text: 'something'
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
            something = OpenStruct.new text: 'something'
            Representers::Something.new(something).to_hash
          else
            error = OpenStruct.new code: 'some_error', message: 'Some error'
            Representers::Error.new(error).to_hash
          end
        end

        add_swagger_documentation
      end
    end
  end

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
          'items' => { '$ref' => '#/definitions/Something' }
        }
      }
    )
  end

  it 'should document specified models as show action' do
    expect(subject['paths']['/something/{id}']['get']['responses']).to eq(
      '200' => {
        'description' => 'OK',
        'schema' => { '$ref' => '#/definitions/Something' }
      },
      '403' => {
        'description' => 'Refused to return something',
        'schema' => { '$ref' => '#/definitions/Error' }
      }
    )
    expect(subject['definitions'].keys).to include 'Error'
    expect(subject['definitions']['Error']).to eq(
      'type' => 'object',
      'description' => 'This returns something',
      'properties' => {
        'code' => { 'type' => 'string', 'description' => 'Error code' },
        'message' => { 'type' => 'string', 'description' => 'Error message' }
      }
    )

    expect(subject['definitions'].keys).to include 'Something'
    expect(subject['definitions']['Something']).to eq(
      'type' => 'object',
      'description' => 'This returns something',
      'properties' => {
        'text' => { 'description' => 'Content of something.', 'type' => 'string' },
        'alias' => { 'description' => 'Aliased.', 'type' => 'string' },
        'kind' => { '$ref' => '#/definitions/Kind', 'description' => 'The kind of this something.' },
        'kind2' => {
          'type' => 'object',
          'properties' => {
            'id' => { 'description' => 'Title of the kind.', 'type' => 'integer', 'format' => 'int32', 'example' => 123 },
            'name' => { 'description' => 'Kind name.', 'type' => 'string' }
          },
          'description' => 'Secondary kind.'
        },
        'kind3' => { '$ref' => '#/definitions/Kind', 'description' => 'Tertiary kind.' },
        'tags' => {
          'type' => 'array',
          'items' => {
            'type' => 'object',
            'properties' => {
              'name' => { 'description' => 'Name', 'type' => 'string', 'example' => 'A tag' },
              'color' => { 'description' => 'Tag color.', 'type' => 'string' }
            }
          },
          'description' => 'Tags.'
        }
      }
    )

    expect(subject['definitions'].keys).to include 'Kind'
    expect(subject['definitions']['Kind']).to eq(
      'type' => 'object', 'properties' => { 'id' => { 'description' => 'Title of the kind.', 'type' => 'integer', 'format' => 'int32', 'example' => 123 } }
    )
  end
end
