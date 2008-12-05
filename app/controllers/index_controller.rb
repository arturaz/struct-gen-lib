class IndexController < ApplicationController
  def index
    @structurograme = StructurogrameModel.new(params[:structurograme])
    if request.post?
      if @structurograme.valid?
        if request.xhr?
          session[:params] = @structurograme.params
          render :json => {
            :image_source => url_for(
              :action => :get_structurograme,
              :id => (rand * 1000000000000).to_i
            )
          }
        else
          render_png
        end
      elsif request.xhr?
        render :json => {
          :errors => render_to_string(:partial => 'errors', 
            :locals => {:errors => @structurograme.errors})
        }
      end
    end
  end
  
  def get_structurograme
    @structurograme = StructurogrameModel.new(session[:params])
    render_png
  end
  
  private
  def render_png
    headers["Content-Type"] = "image/png"
    render :text => @structurograme.render
  end
end
