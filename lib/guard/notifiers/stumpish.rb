module Guard
  module Notifier

    # Notifis using StumpWM Stumpish
    # shows messages in the status bar.
    #
    # @example Add the `:stumpish` notifier to your `Guardfile`
    # notification :stumpish
    #
    module Stumpish
      extend self

      # Default options for Stumpish
      DEFAULTS = {
        :failed  => 1,
        :success => 2
      }

      # Test if the stumpish notification option is available?
      #
      # @param [Boolean] silent true if no error messages should be shown
      # @param [Hash] options notifier options
      # @return [Boolean] the availability status
      #
      def available?(silent = false, options = {})
        `which stumpish 2>&1` && $?.success?
      end

      # Notify using stumpish
      #
      # @param [String] type the notification type. Either 'success', 'pending', 'failed' or 'notify'
      # @param [String] title the notification title
      # @param [String] message the notification message body
      # @param [String] image the path to the notification image
      # @param [Hash] options additional notification library options
      # @option options [String] color_location the location where to draw the color notification
      # @option options [Boolean] display_message whether to display a message or not
      #
      def notify(type, title, message, image, options = { })
        run_client "stumpish echo ^#{stumpish_color(type, options)}*'Guard:'" + description(type, message)
      end

      private

      def run_client(command)
        system(command + " >/dev/null 2>&1")
      end

      def stumpish_color(type, options)
        case type
        when "success"
          options[:success] || DEFAULTS[:success]
        when "failed"
          options[:failed]  || DEFAULTS[:failed]
        when "pending"
          options[:failed]  || DEFAULTS[:failed]
        else
          options[:failed]  || DEFAULTS[:failed]
        end
      end

      def description(type, message)
        state = case type
        when "success"
          ":D"
        when "failed"
          ":'("
        when "pending"
          ":p"
        else
          ":)"
        end
        "\" test #{type} #{state} \n\n#{message}\""
      end
    end

  end
end

