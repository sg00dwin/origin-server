require 'yaml'
class DownloadController < ApplicationController
  before_filter :require_login

  def index
    redirect_to opensource_download_path
  end

  def show
    begin
      download = Download.find params[:id]
      send_file download.path, :type=>download.type and return
      redirect_to root_path
    rescue Download::NotFound
      redirect_to root_path
    end
  end
end
