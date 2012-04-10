class OpensourceController < SiteController
  def index
    redirect_to opensource_download_path
  end

  def download
    @openshift_github_url = "https://github.com/openshift"
    @openshift_cartridges_github_url = "#{@openshift_github_url}/cartridges/master/tree"
  end
end
