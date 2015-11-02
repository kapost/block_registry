require 'block_registry/errors'
require 'block_registry/version'
require 'set'

class BlockRegistry
  def initialize
    self.mappings = {}
  end

  def register(key, &block)
    mappings[key] ||= Set.new
    mappings[key] << block
  end

  def unregister(key, &block)
    raise UnregisteredError, "\"#{key}\" is not registered" unless registered?(key)

    if block_given?
      mappings[key].delete?(block)
      mappings.delete(key) if mappings[key].empty?
    else
      mappings.delete(key)
    end
  end

  def registered?(key)
    mappings.has_key?(key)
  end
  alias_method :handles?, :registered?

  def handle(key, *args)
    raise UnregisteredError, "\"#{key}\" is not registered" unless registered?(key)

    mappings[key].each do |mapping|
      mapping.call(*args)
    end
  end

  private

  attr_accessor :mappings
end
