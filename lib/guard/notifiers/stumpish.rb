require 'guard/notifiers/base'

module Guard
  module Notifier

    # Notifis using StumpWM Stumpish
    # shows messages in the status bar.
    #
    # @example Add the `:stumpish` notifier to your `Guardfile`
    # notification :stumpish
    #
    class Stumpish < Base

      # Default options for Stumpish
      DEFAULTS = {
        :failed  => 1,
        :success => 2,
        :pending => 3
      }

      def self.supported_hosts
        %w[linux]
      end

      def self.available?(opts = {})
        `which stumpish 2>&1` && $?.success? && super
      end

      # Notify using stumpish
      #
      # @param [String] message the notification message body
      # @param [Hash] opts additional notification library options
      # @option opts [String] type the notification type. Either 'success',
      #   'pending', 'failed' or 'notify'
      # @option opts [String] title the notification title
      # @option opts [String] image the path to the notification image
      # @option opts [Boolean] sticky make the notification sticky
      # @option opts [String, Integer] priority specify an int or named key
      #   (default is 0)
      # @option opts [String] host the hostname or IP address to which to
      #   send a remote notification
      # @option opts [String] password the password used for remote
      #   notifications
      def notify(message, opts = { })
        run_client "stumpish echo ^#{stumpish_color_with(opts)}*" + description(message, opts)
      end

      private

      def run_client(command)
        system(command + " >/dev/null 2>&1")
      end

      def stumpish_color_with(opts)
        case opts[:type] || opts[:image]
        when :success
          opts[:success] || DEFAULTS[:success]
        when :failed
          opts[:failed]  || DEFAULTS[:failed]
        when :pending
          opts[:pending] || DEFAULTS[:pending]
        when :notify
          opts[:notify]  || DEFAULTS[:pending]
        else
          opts[:failed]  || DEFAULTS[:failed]
        end
      end

      def description(message, opts)
        mood = \
          case opts[:type] || opts[:image]
          when :success
            ":D"
          when :failed
            ":'("
          when :pending
            ":p"
          when :notify
            ":)"
          else
            ":|"
          end
        "\" Guard: \n #{opts[:title]} #{opts[:type]} #{mood} \n #{message.gsub("\n", "\n ")}  \"\n"
      end
    end

  end
end
