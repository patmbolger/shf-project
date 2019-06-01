# Errors
#  All errors raised by any of the steps defined in our code should be a
#  subclass of SHFStepsError.  This allows us to discriminate and thus rescue
#  error that arise from our code vs. all other errors.
#
#  Define any specific errors in this file.
#
#  See the RSpec in spec/features/support/cucumber_steps_errors_spec.rb for examples
#
# @ref NestedExceptions: http://wiki.c2.com/?NestedException


# ---------------------------------------------
# @module SHFMessageFormatter
#
# @description Helpers for formatting messages
#
module SHFMessageFormatter

  # @return [String] - If str is empty, return an empty string, else return it with single quotes around it
  def empty_or_quoted(str)
    str.blank? ? '' : "'#{str}'"
  end


  # @return [String] -  If a string is not blank, put a space before it if space_before is true, else put the space after it
  def space(str, space_before = true)
    str.blank? ? '' : (space_before ? " #{str}" : "#{str} ")
  end
end



# ---------------------------------------------
#
# @class SHFStepsError
#
# @description Parent class for all errors raised by any of our steps.
#   This can track an 'original_error_message': an error that may have been raised
#   this.  This can be used to help provide context when printing out the
#   message for this error; it helps to keep errors from being 'swallowed'
#   or disappeared during a chain of errors.
#
class SHFStepsError < StandardError
  include SHFMessageFormatter

  attr_reader :original_error_message

  # If there is an error message in the global variable '$!' then this will
  # use it. This enables the object to “magically” discover the originating
  # exception message on initialization.
  def initialize
    super
    @original_error_message = $! # This is the message of the last raised exception
  end


  # If the originating error message is blank or is this class, just show the name of this class
  # else also show the originating error message.
  #
  def message
    if original_error_message.blank? || original_error_message.class == self.class
      self.class.name
    else
      "#{self.class.name}: This was raised after this error: #{self.original_error_message}."
    end
  end

  def message
    if self.cause
      "#{self.class.name}: This was raised after this error: #{self.cause.message}."
    else
      self.class.name
    end
  end
end


# ---------------------------------------------
#
# @class PathHelperError
#
# @description Raised with any error that happens when trying to construct a path to visit.
#   Raise this if there is an error and it is _not_ covered by one of its subclasses.
#
#   The error message will always be the message from the super class followed
#   by any information specific to the error.
#
class PathHelperError < SHFStepsError

  MAYBE_ADD_TO_KNOWN_PAGES_PATHS = "You may need to add it to the list of known paths in the get_path() case statement." unless defined?(MAYBE_ADD_TO_KNOWN_PAGES_PATHS)


  def message
    "#{super}:#{space(message_for_this_error)}"
  end


  # ----------------------------------


  protected


  # Subclasses can override this if they need to include additional information
  def message_for_this_error
    ''
  end
end


# ---------------------------------------------
#
# @class PagenameUnknown
#
# @description Raised if the page name given is not one known in the explicit list in the
# :get_path method (the case statement in it).
#
class PagenameUnknown < PathHelperError

  attr_accessor :page_name


  def initialize(page_name: '')
    super()
    @page_name = page_name
  end


  protected


  def message_for_this_error
    "The page name#{space(empty_or_quoted(self.page_name))} is unknown.\n  #{MAYBE_ADD_TO_KNOWN_PAGES_PATHS}"
  end
end


# ---------------------------------------------
#
# @class UnableToVisitConstructedPath
#
# @description Raised if there was a problem visiting the path manually constructed.
# The path might not be known or there might have been a problem with the actual :visit .
# (The caller will need to be specific about which errors are rescued in order to tell.)
#
class UnableToVisitConstructedPath < PathHelperError

  attr_accessor :constructed_path


  def initialize(constructed_path: '')
    super()
    @constructed_path = constructed_path
  end


  protected


  def message_for_this_error
    "Unable to visit the manually constructed path#{space(empty_or_quoted(self.constructed_path))}.\n  #{MAYBE_ADD_TO_KNOWN_PAGES_PATHS}"
  end
end
