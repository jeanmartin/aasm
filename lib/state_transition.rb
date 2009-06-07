module AASM

  # When raising a guard failure, simply give an explanation i.e. "the value is not in the allowed range" similar to
  # the :message specification for AR validations.
  class GuardFailure < RuntimeError; end

  module SupportingClasses
    class StateTransition
      attr_reader :from, :to, :opts

      def initialize(opts)
        @from, @to, @guard, @on_transition, @failure_message = opts[:from], opts[:to], opts[:guard], opts[:on_transition], opts[:failure_message]
        @opts = opts
      end

      def perform(obj)
        result = begin
          guard_result = case @guard
          when Symbol, String
            obj.send(@guard)
          when Proc
            @guard.call(obj)
          else
            true
          end

          # Catch generic false return with no exception raised
          raise(GuardFailure, "the guard process did not pass") unless guard_result

        rescue GuardFailure => e
          obj.errors.send(:add, obj.class.aasm_column.to_sym, "is invalid because #{e.message}")
          false
        else
          true
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
