require 'spec_helper'

describe 'responseModel' do
  before :all do
    module ThisApi
      module Representers
        class Kind < Representable::Decorator
          include Representable::JSON

          property :title, documentation: { type: 'string', desc: 'Title of the kind.', example: 123 }
        end

        class Relation < Representable::Decorator
          include Representable::JSON

          property :name, type: 'string', desc: 'RelationName', documentation: { type: 'string', desc: 'Name', example: -> { 'A relation' } }
        end

        class Tag < Representable::Decorator
          include Representable::JSON

          property :name, type: 'string', desc: 'Name'
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
          property :kind2, decorator: Kind, documentation: { desc: 'Secondary kind.' }
          property :kind3, decorator: ThisApi::Representers::Kind, documentation: { desc: 'Tertiary kind.' }
          collection :tags, decorator: ThisApi::Representers::Tag, documentation: { desc: 'Tags.' }
          property :relation, decorator: ThisApi::Representers::Relation, documentation: { desc: 'A related model.' }
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
    ThisApi::ResponseModelApi
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
      'properties' => { 'code' => { 'description' => 'Error code', 'type' => 'string' }, 'message' => { 'description' => 'Error message', 'type' => 'string' } }
    )

    expect(subject['definitions'].keys).to include 'Something'
    expect(subject['definitions']['Something']).to eq(
      'type' => 'object',
      'description' => 'This returns something',
      'properties' =>
          { 'text' => { 'type' => 'string', 'description' => 'Content of something.' },
            'alias' => { 'type' => 'string', 'description' => 'Aliased.' },
            'kind' => { '$ref' => '#/definitions/Kind', 'description' => 'The kind of this something.' },
            'kind2' => { '$ref' => '#/definitions/Kind', 'description' => 'Secondary kind.' },
            'kind3' => { '$ref' => '#/definitions/Kind', 'description' => 'Tertiary kind.' },
            'tags' => { 'type' => 'array', 'items' => { '$ref' => '#/definitions/Tag' }, 'description' => 'Tags.' },
            'relation' => { '$ref' => '#/definitions/Relation', 'description' => 'A related model.' } }
    )

    expect(subject['definitions'].keys).to include 'Kind'
    expect(subject['definitions']['Kind']).to eq(
      'type' => 'object', 'properties' => { 'title' => { 'type' => 'string', 'description' => 'Title of the kind.', 'example' => 123 } }
    )

    expect(subject['definitions'].keys).to include 'Relation'
    expect(subject['definitions']['Relation']).to eq(
      'type' => 'object', 'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name', 'example' => 'A relation' } }
    )

    expect(subject['definitions'].keys).to include 'Tag'
    expect(subject['definitions']['Tag']).to eq(
      'type' => 'object', 'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name' } }
    )
  end
end

describe 'should build definition from given entity' do
  before :all do
    module TheseApi
      module Representers
        class Kind < Representable::Decorator
          include Representable::JSON

          property :id, documentation: { type: Integer, desc: 'Title of the kind.' }
        end

        class Relation < Representable::Decorator
          include Representable::JSON

          property :name, documentation: { type: String, desc: 'Name' }
        end

        class Tag < Representable::Decorator
          include Representable::JSON

          property :name, documentation: { type: 'string', desc: 'Name' }
        end

        class SomeEntity < Representable::Decorator
          include Representable::JSON

          property :text, documentation: { type: 'string', desc: 'Content of something.' }
          property :kind, decorator: Kind, documentation: { desc: 'The kind of this something.' }
          property :kind2, decorator: Kind, documentation: { desc: 'Secondary kind.' }
          property :kind3, decorator: TheseApi::Representers::Kind, documentation: { desc: 'Tertiary kind.' }
          collection :tags, decorator: TheseApi::Representers::Tag, documentation: { desc: 'Tags.' }
          property :relation, decorator: TheseApi::Representers::Relation, documentation: { desc: 'A related model.' }
        end
      end

      class ResponseEntityApi < Grape::API
        format :json
        desc 'This returns something',
             is_array: true,
             entity: Representers::SomeEntity
        get '/some_entity' do
          something = OpenStruct.new text: 'something'
          Representers::SomeEntity.new(something).to_hash
        end

        add_swagger_documentation
      end
    end
  end

  def app
    TheseApi::ResponseEntityApi
  end

  subject do
    get '/swagger_doc'
    JSON.parse(last_response.body)
  end

  it 'it prefer entity over others' do
    expect(subject['definitions']).to eql(
      'Kind' => { 'type' => 'object', 'properties' => { 'id' => { 'description' => 'Title of the kind.', 'type' => 'integer', 'format' => 'int32' } } },
      'Tag' => { 'type' => 'object', 'properties' => { 'name' => { 'description' => 'Name', 'type' => 'string' } } },
      'Relation' => { 'type' => 'object', 'properties' => { 'name' => { 'description' => 'Name', 'type' => 'string' } } },
      'SomeEntity' => {
        'type' => 'object',
        'properties' => {
          'text' => { 'description' => 'Content of something.', 'type' => 'string' },
          'kind' => { '$ref' => '#/definitions/Kind', 'description' => 'The kind of this something.' },
          'kind2' => { '$ref' => '#/definitions/Kind', 'description' => 'Secondary kind.' },
          'kind3' => { '$ref' => '#/definitions/Kind', 'description' => 'Tertiary kind.' },
          'tags' => { 'type' => 'array', 'items' => { '$ref' => '#/definitions/Tag' }, 'description' => 'Tags.' },
          'relation' => { '$ref' => '#/definitions/Relation', 'description' => 'A related model.' }
        },
        'description' => 'This returns something'
      }
    )
  end
end
