class OpensourceController < SiteController
  def index
    redirect_to opensource_download_path
  end

  def download
    @openshift_github_path = "https://github.com/openshift"
  end
end
