# frozen_string_literal: true

require_relative "node"

module LibraryTree
  # Thread-safe registry of tracked modules and their relationships
  module Registry
    # Return the registry mutex
    # @return [Mutex]
    def mutex
      @mutex ||= Mutex.new # rubocop:disable ThreadSafety/ClassInstanceVariable
    end
    module_function :mutex

    # Internal storage of nodes keyed by Module
    # @return [Hash{Module=>LibraryTree::Node}]
    def nodes
      @nodes ||= {} # rubocop:disable ThreadSafety/ClassInstanceVariable
    end
    module_function :nodes

    # Check if a module is being tracked
    # @param mod [Module]
    # @return [Boolean]
    def tracked?(mod)
      nodes.key?(mod)
    end
    module_function :tracked?

    # Ensure a Node exists for the given module, creating it if needed
    # @param mod [Module]
    # @return [LibraryTree::Node]
    def ensure_node(mod)
      nodes[mod] ||= Node.new(mod)
    end
    module_function :ensure_node

    # Mark a module as tracked
    # @param mod [Module]
    # @return [void]
    def mark_tracked(mod)
      mutex.synchronize do
        ensure_node(mod)
      end
    end
    module_function :mark_tracked

    # Create a link parent -> child (including_module -> included_module)
    # Ruby 1.9.2+ compatible: use positional parameters instead of keyword arguments
    # @param parent [Module] including module
    # @param child [Module] included module
    # @return [void]
    def link(parent, child)
      mutex.synchronize do
        pnode = ensure_node(parent)
        cnode = ensure_node(child)
        pnode.add_child(cnode)
        cnode.add_parent(pnode)
      end
    end
    module_function :link

    # Return all root nodes
    # @return [Array<LibraryTree::Node>]
    def roots
      mutex.synchronize do
        nodes.values.select(&:root?)
      end
    end
    module_function :roots

    # Return all known nodes
    # @return [Array<LibraryTree::Node>]
    def all
      mutex.synchronize do
        nodes.values
      end
    end
    module_function :all

    # Reset the registry to an empty state
    # @return [void]
    def reset!
      mutex.synchronize do
        @nodes = {}
      end
    end
    module_function :reset!
  end
end
