#
# With both digest and asset compilation disabled, Rails incorrectly
# fails to return paths to resources that were precompiled.
#
# Potentially needs to be brought upstream.
#
class Sprockets::Helpers::RailsHelper::AssetPaths
  def digest_for(logical_path)
    # CHANGED
    return logical_path if !compile_assets && !digest_assets
    # END CHANGED

    if digest_assets && asset_digests && (digest = asset_digests[logical_path])
      return digest
    end

    if compile_assets
      if digest_assets && asset = asset_environment[logical_path]
        return asset.digest_path
      end
      return logical_path
    else
      raise AssetNotPrecompiledError.new("#{logical_path} isn't precompiled")
    end
  end
end
