# frozen_string_literal: true

require_relative "library_tree/version"
require_relative "library_tree/watcher"
require_relative "library_tree/registry"

module LibraryTree
  class Error < StandardError; end

  class << self
    # Return array of root nodes (modules without parents)
    def roots
      Registry.roots
    end

    # Return all nodes
    def nodes
      Registry.all
    end

    # Render the forest as a string
    def render
      roots.map { |r| r.render }.join
    end

    # Testing/utility: reset the registry
    def reset!
      Registry.reset!
    end
  end
end
