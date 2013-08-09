module Izzle
  module HasEasy
    class Configurator
      
      attr_accessor :definitions, :aliases
      
      def initialize(klass, name, options)
        @klass = klass
        @name = name
        @definitions = {}
        @options = options

        @aliases = []
        if options.has_key?(:aliases)
          @aliases = options[:aliases]
        elsif options.has_key?(:alias)
          @aliases = [options[:alias]]
        end
        @aliases = @aliases.collect{ |a| a.to_s }
      end
      
      def define(name, options = {})
        name = Helpers.normalize(name)
        raise ArgumentError, "class #{@klass} has_easy('#{@name}') already defines '#{name}'" if @definitions.has_key?(name)
        @definitions[name] = Definition.new(name, options)
      end

      def define_boolean(name, options = {})
        truevalue = options.delete(:true) || '1'
        falsevalue = options.delete(:false) || '0'
        booloptions = {
                :type_check => [TrueClass, FalseClass],
                :preprocess => Proc.new{ |value| value == truevalue },
                :postprocess => Proc.new{ |value| value ? truevalue : falsevalue }
        }
        define(name, booloptions.merge(options))
      end

      def do_metaprogramming_magic_aka_define_methods
        
        easy_accessors, object_accessors, accessible_names  = [], [], []
        @definitions.values.each do |definition|

          easy_accessors << <<-end_eval
            def #{@name}_#{definition.name}=(value)
              set_has_easy_thing('#{@name}', '#{definition.name}', value, true)
            end
            def #{@name}_#{definition.name}
              get_has_easy_thing('#{@name}', '#{definition.name}', true)
            end
            def #{@name}_#{definition.name}?
              !!get_has_easy_thing('#{@name}', '#{definition.name}', true)
            end
          end_eval

          accessible_names << ":#{@name}_#{definition.name}" if @options[:accessible]

          object_accessors << <<-end_eval
            def #{definition.name}=(value)
              proxy_association.owner.set_has_easy_thing('#{@name}', '#{definition.name}', value)
            end
            def #{definition.name}
              proxy_association.owner.get_has_easy_thing('#{@name}', '#{definition.name}')
            end
            def #{definition.name}?
              !!proxy_association.owner.get_has_easy_thing('#{@name}', '#{definition.name}')
            end
          end_eval
        end
        
        method_aliases = @aliases.inject([]) do |memo, alias_name|
          memo << "alias_method :#{alias_name}, :#{@name}"
          @definitions.values.each do |definition|
            memo << "alias_method :#{alias_name}_#{definition.name}=, :#{@name}_#{definition.name}="
            memo << "alias_method :#{alias_name}_#{definition.name},  :#{@name}_#{definition.name}"
            memo << "alias_method :#{alias_name}_#{definition.name}?, :#{@name}_#{definition.name}?"
            accessible_names << ":#{alias_name}_#{definition.name}" if @options[:accessible]
          end
          memo
        end
        
        @klass.class_eval <<-end_eval
          # first define the has many relationship
          has_many :#{@name}, :class_name => 'HasEasyThing',
                              :as => :model,
                              :extend => AssocationExtension,
                              :autosave => #{@options[:autosave] ? 'true' : 'false'},
                              :dependent => :destroy do
            #{object_accessors.join("\n")}
          end
          
          # now define the easy accessors
          #{easy_accessors.join("\n")}
          
          # define the aliases
          #{method_aliases.join("\n")}
        end_eval

        if accessible_names.size > 0 
          @klass.class_eval <<-end_eval
            attr_accessible #{accessible_names.join(', ')}
          end_eval
        end

      end
      
    end
  end
end
