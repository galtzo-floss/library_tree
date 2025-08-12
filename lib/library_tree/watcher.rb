# frozen_string_literal: true

require_relative "registry"

module LibraryTree
  # Public API module to enable watching on modules that include it.
  # When a watched module is included into another watched module, a link is recorded.
  module Watcher
    module ClassMethods
      # Called whenever the watched module (`self`) is included into another module (`base`).
      # @param base [Module] the including module
      # @return [void]
      def included(base)
        super
        # Link whenever the included module (self) is tracked, regardless of whether the includer (base) is tracked.
        if LibraryTree::Registry.tracked?(self)
          LibraryTree::Registry.link(base, self)
        end
      end
    end

    class << self
      # Mark the including module as tracked and extend it to observe future inclusions
      # @param mod [Module]
      # @return [void]
      def included(mod)
        # Mark the module itself as tracked
        LibraryTree::Registry.mark_tracked(mod)
        # Ensure we observe future inclusions of this module into other modules
        mod.extend(ClassMethods)
      end
    end
  end
end
