module OpenShiftMigration
  class MigrationProgress 
    def initialize(uuid)
      @uuid = uuid
    end

    def incomplete?(marker)
      not complete?(marker)
    end

    def complete?(marker)
      File.exists?(marker_path(marker))
    end

    def mark_complete(marker)
      IO.write(marker_path(marker), '')
      "Marking step #{marker} complete\n"
    end

    def clear
      Dir.glob(File.join('/var/lib/openshift', @uuid, 'app-root', 'data', '.migration_complete*')).each do |entry|
        FileUtils.rm_rf(entry)
      end
    end

    def marker_path(marker)
      File.join('/var/lib/openshift', @uuid, 'app-root', 'data', ".migration_complete_#{marker}")
    end
  end
end