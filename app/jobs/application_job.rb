class ApplicationJob < ActiveJob::Base

  def perform
    # put you scheduled code here
    # Comments.deleted.clean_up...
  end

end
