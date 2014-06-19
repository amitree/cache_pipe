require 'delegate'
require 'active_support/cache/cache_pipe'

describe ActiveSupport::Cache::CachePipe do
  let(:internal_cache) { Hash.new }
  subject { ActiveSupport::Cache::CachePipe.new :wrap_nil, :internal_cache }

  before do
    allow(ActiveSupport::Cache).to receive(:lookup_store).with(:internal_cache).and_return internal_cache

    # Override fetch because Hash.fetch doesn't take options
    allow(internal_cache).to receive(:fetch) do |key, options, &block|
      if internal_cache.has_key?(key) || block.nil?
        internal_cache[key]
      else
        internal_cache[key] = block.call
      end
    end

    allow(internal_cache).to receive(:read) do |key, options|
      internal_cache[key]
    end

    allow(internal_cache).to receive(:write) do |key, value, options|
      internal_cache[key] = value
    end
  end

  describe '#fetch' do
    context 'with a block' do
      context 'cache hit' do
        before do
          internal_cache[:key] = ActiveSupport::Cache::CachePipe::NIL_VALUE
        end

        it 'should not call the block' do
          subject.fetch :key do @called = true; end
          expect(@called).to be nil
        end
      end

      context 'cache miss' do
        it 'should call the block' do
          subject.fetch :key do @called = true; end
          expect(@called).to be true
        end
      end
    end

    context 'without block' do
      context 'cache hit' do
        it 'should return nil if nil is stored' do
          internal_cache[:key] = ActiveSupport::Cache::CachePipe::NIL_VALUE
          expect(subject.fetch :key).to be nil
        end
        it 'should return non-nil if non-nil is stored' do
          internal_cache[:key] = 'hi'
          expect(subject.fetch :key).to eq 'hi'
        end
      end

      context 'cache miss' do
        it 'should return nil' do
          expect(subject.fetch :key).to be nil
        end
      end
    end
  end

  describe '#read' do
    it 'reads non-nil values correctly' do
      internal_cache[:key] = 'hi'
      expect(subject.read :key).to eq 'hi'
    end

    it 'returns nil when a nil value is stored' do
      internal_cache[:key] = ActiveSupport::Cache::CachePipe::NIL_VALUE
      expect(subject.read :key).to be nil
    end

    it 'returns nil when a different nil value is stored' do
      internal_cache[:key] = ActiveSupport::Cache::CachePipe::WrappedNil.new
      expect(subject.read :key).to be nil
    end

    it 'returns nil on cache miss' do
      expect(subject.read :key).to be nil
    end
  end

  describe '#write' do
    it 'writes non-nil values correctly' do
      subject.write :key, 'hi'
      expect(internal_cache[:key]).to eq 'hi'
    end

    it 'writes nil values correctly' do
      subject.write :key, nil
      expect(internal_cache[:key]).to eq ActiveSupport::Cache::CachePipe::NIL_VALUE
    end
  end
end
