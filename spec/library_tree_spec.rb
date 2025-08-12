# frozen_string_literal: true

RSpec.describe LibraryTree do
  before { described_class.reset! }

  describe "Watcher tracking" do
    module LTSpecA; end

    module LTSpecB; end

    module LTSpecC; end

    it "links parent->child when both sides are watched and inclusion happens" do
      LTSpecA.module_eval { include LibraryTree::Watcher }
      LTSpecB.module_eval { include LibraryTree::Watcher }
      LTSpecC.module_eval { include LibraryTree::Watcher }

      # Build a chain A -> B -> C
      LTSpecA.module_eval { include LTSpecB }
      LTSpecB.module_eval { include LTSpecC }

      roots = described_class.roots
      expect(roots.map(&:mod)).to include(LTSpecA)
      a = roots.find { |n| n.mod == LTSpecA }
      expect(a.children.map(&:mod)).to include(LTSpecB)
      b = a.children.find { |n| n.mod == LTSpecB }
      expect(b.children.map(&:mod)).to include(LTSpecC)

      # Including the same module again should not duplicate edges
      LTSpecA.module_eval { include LTSpecB }
      expect(a.children.select { |n| n.mod == LTSpecB }.size).to eq(1)
    end

    it "links even if the base is not watched (3rd-degree inclusion)" do
      module LTSpecUnwatched; end
      LTSpecC.module_eval { include LibraryTree::Watcher }
      LTSpecUnwatched.module_eval { include LTSpecC }

      # Even though base isn't watched, inclusion of a watched module should be tracked
      node_c = described_class.nodes.find { |n| n.mod == LTSpecC }
      expect(node_c.parents.map(&:mod)).to include(LTSpecUnwatched)
    end

    it "can render and handle cycles without infinite recursion" do
      LTSpecA.module_eval { include LibraryTree::Watcher }
      LTSpecB.module_eval { include LibraryTree::Watcher }

      LTSpecA.module_eval { include LTSpecB } # A -> B
      # Force a cycle for test purposes
      LibraryTree::Registry.link(LTSpecB, LTSpecA) # B -> A

      roots = described_class.roots
      expect(roots).to eq([])

      # Depending on cycle, roots may be empty; render all nodes instead
      output = described_class.nodes.map { |n| n.render }.join
      expect(output).to include("(…cycle…)")

      # And to_h should also not loop infinitely
      hashes = described_class.nodes.map(&:to_h)
      expect(hashes).to all(be_a(Hash))
    end

    it "LibraryTree.render returns empty string when there are no roots" do
      # no watched modules; roots should be empty
      expect(described_class.roots).to eq([])
      expect(described_class.render).to eq("")
    end

    it "LibraryTree.render outputs tree for a simple chain" do
      LTSpecA.module_eval { include LibraryTree::Watcher }
      LTSpecB.module_eval { include LibraryTree::Watcher }

      LTSpecA.module_eval { include LTSpecB }

      output = described_class.render
      expect(output).to include("* LTSpecA")
      expect(output).to include("  * LTSpecB")
    end

    it "does not link when the included module is not tracked" do
      # Create an untracked module that only has the inclusion callback
      untracked = Module.new
      base = Module.new
      # Manually extend the ClassMethods so `included` is called, but do NOT mark it tracked
      untracked.extend(LibraryTree::Watcher::ClassMethods)

      # Include the untracked module into a base module; since it's not tracked, no link should be created
      base.module_eval { include untracked }

      # Registry should still be empty (no nodes created)
      expect(described_class.nodes).to eq([])
      expect(described_class.roots).to eq([])
    end

    context "when a big chain is involved" do
      # Write a generator method to create a chain of modules, with branching,
      #   and with interleaved modules that do not include Watcher.
      # There should be multiple roots, top-level modules that include the watcher.
      #   Some of the included modules will be included on both sides of the chain, under multiple roots.
      it "LibraryTree.render outputs tree", :check_output do
        # Generator logic: define modules and build a graph with two roots and shared children.
        # Helper to create or fetch a named module constant
        mk = ->(name) do
          if Object.const_defined?(name, false)
            Object.const_get(name)
          else
            Object.const_set(name, Module.new)
          end
        end

        # Watched roots
        r1 = mk.call(:LTBigRoot1)
        r2 = mk.call(:LTBigRoot2)
        # Watched branches
        a = mk.call(:LTBigA)
        b = mk.call(:LTBigB)
        c = mk.call(:LTBigC)
        # Shared watched leaf
        shared = mk.call(:LTBigShared)
        # Unwatched interleaves
        uw1 = mk.call(:LTBigUW1)
        uw2 = mk.call(:LTBigUW2)

        # Watch selected modules (roots and significant nodes)
        r1.module_eval { include LibraryTree::Watcher }
        r2.module_eval { include LibraryTree::Watcher }
        a.module_eval { include LibraryTree::Watcher }
        b.module_eval { include LibraryTree::Watcher }
        c.module_eval { include LibraryTree::Watcher }
        shared.module_eval { include LibraryTree::Watcher }
        # uw1 and uw2 intentionally do NOT include Watcher

        # Build includes (edges are recorded when the included module is watched, regardless of includer)
        # Roots branch to A and B (for Root1), and B and C (for Root2)
        r1.module_eval { include a }
        r1.module_eval { include b }

        r2.module_eval { include b }
        r2.module_eval { include c }

        # Branches point to the same shared leaf
        a.module_eval { include shared }
        b.module_eval { include shared }
        c.module_eval { include shared }

        # Interleave some unwatched modules; only inclusion of a watched module is tracked
        r1.module_eval { include uw1 } # no link tracked (uw1 is unwatched)
        uw1.module_eval { include uw2 } # no link tracked (uw2 is unwatched)
        uw2.module_eval { include shared } # link tracked (shared is watched)

        # Now assert the structures

        # Roots should include the two top-level watched modules; additional roots may exist (e.g., unwatched includers like uw2)
        root_mods = described_class.roots.map(&:mod)
        expect(root_mods).to include(r1, r2)
        # Ensure branch modules are not roots (they have parents)
        expect(root_mods).not_to include(a)
        expect(root_mods).not_to include(b)
        expect(root_mods).not_to include(c)
        expect(root_mods).not_to include(shared)

        output = described_class.render

        # It should render both watched roots
        expect(output).to include("* #{r1.name}")
        expect(output).to include("* #{r2.name}")

        # Root1's branches
        expect(output).to include("  * #{a.name}")
        expect(output).to include("  * #{b.name}")

        # Root2's branches
        # B is shared beneath both roots
        expect(output.scan(/\* #{Regexp.escape(b.name)}/).size).to be >= 2
        expect(output).to include("  * #{c.name}")

        # Shared leaf should appear under A, B (for both roots), C, and UW2 -> total 5 occurrences
        expect(output.scan(/\* #{Regexp.escape(shared.name)}/).size).to eq(5)

        puts output if DEBUGGING
      end
    end
  end
end
