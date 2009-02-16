module AASM
  module SupportingClasses
    class StateTransition
      attr_reader :from, :to, :opts

      def initialize(opts)
        @from, @to, @guard, @on_transition, @failure_message = opts[:from], opts[:to], opts[:guard], opts[:on_transition], opts[:failure_message]
        @opts = opts
      end

      def perform(obj)
        result = case @guard
        when Symbol, String
          obj.send(@guard)
        when Proc
          @guard.call(obj)
        else
          true
        end

        if result
          true
        else
          obj.errors.send(:add, obj.class.aasm_column.to_sym, @failure_message)
          false
        end
      end
      
      def execute(obj, *args)
        case @on_transition
        when Symbol, String
          obj.send(@on_transition, *args)
        when Proc
          @on_transition.call(obj, *args)
        end
      end

      def ==(obj)
        @from == obj.from && @to == obj.to
      end
    end
  end
end
