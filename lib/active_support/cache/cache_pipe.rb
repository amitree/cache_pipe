module ActiveSupport
  module Cache
    class CachePipe < SimpleDelegator
      class WrappedNil ; end

      NIL_VALUE = WrappedNil.new

      #
      # In your environment configruation:
      #   config.cache_store = :cache_pipe, :wrap_nil, :dalli_store, { value_max_bytes: 10485760, expires_in: 86400 }
      #
      # will cause a call to:
      #   ActiveSupport::Cache::CachePipe.new(:wrap_nil, :dalli_store, { value_max_bytes: 10485760, expires_in: 86400 })
      #
      def initialize transformation, *store_options
        super ActiveSupport::Cache.lookup_store(*store_options)
        case transformation
        when :wrap_nil
          @transform_read = :unwrap_nil
          @transform_write = :wrap_nil
        else
          raise "Invalid transformation #{transformation}.  Valid values are: :wrap_nil"
        end
      end

      def fetch name, options=nil
        if block_given?
          transform_read __getobj__.fetch(name, options) { transform_write(yield) }
        else
          transform_read __getobj__.fetch(name, options)
        end
      end

      def read name, options=nil
        transform_read __getobj__.read(name, options)
      end

      def write name, value, options=nil
        __getobj__.write name, transform_write(value), options
      end

    private

      def transform_read value
        send(@transform_read, value)
      end

      def transform_write value
        send(@transform_write, value)
      end

      def wrap_nil value
        case value
        when nil
          NIL_VALUE
        else
          value
        end
      end

      def unwrap_nil(value)
        case value
        when WrappedNil
          nil
        else
          value
        end
      end
    end
  end
end
