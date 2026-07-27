# frozen_string_literal: true

# Ruflet's standalone DSL forwards unknown Kernel calls to extension controls.
# In Rails that fallback intercepts other frameworks' method_missing protocols;
# Arel visitors, for example, become Ruflet controls while compiling SQL.
# Keep Ruflet's explicitly defined helpers, but restore normal Ruby behavior for
# unknown methods in this host application.
module Kernel
  define_method(:method_missing) do |name, *args, **kwargs, &block|
    BasicObject.instance_method(:method_missing).bind_call(self, name, *args, **kwargs, &block)
  end
  private :method_missing
end
