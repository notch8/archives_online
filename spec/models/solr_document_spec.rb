# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocument do
  describe '#campus' do
    context 'when the document is a collection' do
      let(:doc) do
        described_class.new(
          id: 'collection123',
          campus_unit_ssm: ['UCLA'],
          level_ssm: ['collection']
        )
      end

      it 'returns the first campus_unit_ssm value' do
        allow(doc).to receive(:collection?).and_return(true)
        expect(doc.campus).to eq('UCLA')
      end
    end

    context 'when the document is not a collection' do
      let(:doc) do
        described_class.new(
          id: 'item456',
          campus_unit_ssm: ['Berkeley'],
          level_ssm: ['item']
        )
      end

      it 'returns the first value from the collection field' do
        fake_collection = double('collection', first: 'Berkeley')
        allow(doc).to receive(:collection).and_return(fake_collection)
        allow(doc).to receive(:collection?).and_return(false)
        expect(doc.campus).to eq('Berkeley')
      end
    end
  end
end
