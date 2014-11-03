class Owner::FirstStepsController < Owner::BaseController

  def show
    respond_to do |format|
      format.json { json_render partial: 'sample_profile' }
      format.html
    end
  end
end