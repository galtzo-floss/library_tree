# frozen_string_literal: true

require_relative "node"

module LibraryTree
  # Thread-safe registry of tracked modules and their relationships
  module Registry
    module_function

    def mutex
      @mutex ||= Mutex.new
    end

    def nodes
      @nodes ||= {}
    end

    def tracked?(mod)
      nodes.key?(mod)
    end

    def ensure_node(mod)
      nodes[mod] ||= Node.new(mod)
    end

    def mark_tracked(mod)
      mutex.synchronize do
        ensure_node(mod)
      end
    end

    # Create a link parent -> child (including_module -> included_module)
    def link(parent:, child:)
      mutex.synchronize do
        pnode = ensure_node(parent)
        cnode = ensure_node(child)
        pnode.add_child(cnode)
        cnode.add_parent(pnode)
      end
    end

    def roots
      mutex.synchronize do
        nodes.values.select(&:root?)
      end
    end

    def all
      mutex.synchronize do
        nodes.values
      end
    end

    def reset!
      mutex.synchronize do
        @nodes = {}
      end
    end
  end
end
