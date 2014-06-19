# cache\_pipe

Provides a wrapper around a Rails cache store, allowing values to be
transformed before storage and after retrieval.

Currently it provides a single transformation, `:wrap_nil`, which allows
caching engines like [Dalli](https://github.com/mperham/dalli) to store `nil`
values.

## Usage

Add to your Gemfile:

```ruby
gem 'cache_pipe'
```

Then change your Rails configuration, e.g. `config/environments/production.rb`:

```ruby
config.cache_store = :cache_pipe, :wrap_nil, :dalli_store, { value_max_bytes: 10485760, expires_in: 86400 }
# Instead of config.cache_store = :dalli_store, { value_max_bytes: 10485760, expires_in: 86400 }
```

## TODO

In the future, we may want to support additional transformations.  Let me know
if you have other applications that aren't covered by the current
implementation!
