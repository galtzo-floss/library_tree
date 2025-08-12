# frozen_string_literal: true

require_relative "library_tree/version"
require_relative "library_tree/watcher"
require_relative "library_tree/registry"

module LibraryTree
  # Main namespace for LibraryTree. Provides convenience accessors to the registry
  # and a renderer for the forest of tracked modules.
  # @see LibraryTree::Watcher
  # @see LibraryTree::Registry
  # @see LibraryTree::Node
  # @see LibraryTree::Version
  # Generic error class for LibraryTree
  class Error < StandardError; end

  class << self
    # Return array of root nodes (modules without parents)
    # @return [Array<LibraryTree::Node>] an array of nodes that have no parents
    def roots
      Registry.roots
    end

    # Return all nodes currently tracked in the registry
    # @return [Array<LibraryTree::Node>] all known nodes
    def nodes
      Registry.all
    end

    # Render the forest as a string
    # @return [String] a textual tree representation of all roots and their descendants
    def render
      roots.map { |r| r.render }.join
    end

    # Testing/utility: reset the registry
    # @return [void]
    def reset!
      Registry.reset!
    end
  end
end
