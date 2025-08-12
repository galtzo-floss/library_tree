# frozen_string_literal: true

module LibraryTree
  # Represents a tracked module and its relationships
  # Parents are modules that include this module
  # Children are modules that this module is included into.
  # In Ruby, when A includes B, A depends on B.
  # We will model edges parent -> child as: including_module -> included_module
  class Node
    attr_reader :mod, :parents, :children

    def initialize(mod)
      @mod = mod
      @parents = [] # Array<Node>
      @children = [] # Array<Node>
    end

    def name
      mod.name || mod.inspect
    end

    def add_child(child)
      return if @children.include?(child)
      @children << child
    end
    
    def add_parent(parent)
      return if @parents.include?(parent)
      @parents << parent
    end

    def root?
      @parents.empty?
    end

    def to_h(seen = {})
      return { name: name } if seen[object_id]
      seen[object_id] = true
      {
        name: name,
        children: children.map { |c| c.to_h(seen) }
      }
    end

    # Render a tree view starting from this node.
    def render(indent = 0, seen = {})
      return "#{'  ' * indent}* #{name} (…cycle…)\n" if seen[object_id]
      seen[object_id] = true
      out = "#{'  ' * indent}* #{name}\n"
      children.each do |child|
        out << child.render(indent + 1, seen.dup)
      end
      out
    end
  end
end
