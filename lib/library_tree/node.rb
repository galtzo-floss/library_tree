# frozen_string_literal: true

module LibraryTree
  # Represents a tracked module and its relationships
  # Parents are modules that include this module
  # Children are modules that this module is included into.
  # In Ruby, when A includes B, A depends on B.
  # We will model edges parent -> child as: including_module -> included_module
  class Node
    # @return [Module] the underlying Ruby module being tracked
    # @return [Array<LibraryTree::Node>] parents of this node (including modules)
    # @return [Array<LibraryTree::Node>] children of this node (included modules)
    attr_reader :mod, :parents, :children

    # Create a node for a Ruby module
    # @param mod [Module] the module to track
    def initialize(mod)
      @mod = mod
      @parents = [] # Array<Node>
      @children = [] # Array<Node>
    end

    # @return [String] a human-friendly name for the module
    def name
      mod.name || mod.inspect
    end

    # Add a child node (an included module)
    # @param child [LibraryTree::Node]
    # @return [void]
    def add_child(child)
      return if @children.include?(child)
      @children << child
    end

    # Add a parent node (a module that includes this module)
    # @param parent [LibraryTree::Node]
    # @return [void]
    def add_parent(parent)
      return if @parents.include?(parent)
      @parents << parent
    end

    # Whether this node has no parents (it is a root)
    # @return [Boolean]
    def root?
      @parents.empty?
    end

    # Return a Hash representation of this node and its children
    # @param seen [Hash{Integer=>true}] a map of visited node object_ids to avoid cycles
    # @return [Hash{Symbol=>Object}] a tree structure with :name and :children
    def to_h(seen = {})
      return {name: name} if seen[object_id]
      seen[object_id] = true
      {
        name: name,
        children: children.map { |c| c.to_h(seen) },
      }
    end

    # Render a tree view starting from this node.
    # @param indent [Integer] number of levels to indent (default: 0)
    # @param seen [Hash{Integer=>true}] a map of visited node object_ids to avoid cycles
    # @return [String] a multi-line string representing the subtree
    def render(indent = 0, seen = {})
      return "#{"  " * indent}* #{name} (…cycle…)\n" if seen[object_id]
      seen[object_id] = true
      out = "#{"  " * indent}* #{name}\n"
      children.each do |child|
        out += child.render(indent + 1, seen.dup)
      end
      out
    end
  end
end
