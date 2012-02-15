require 'config/environment'

ds = Cloud::Sdk::DataStore.instance
users = ds.class.collection.find({})
users.each do |user|
  print "Processing user #{user["_id"]}\n"
  if user["apps"]
    user["apps"].each do |app|
      print "\tProcessing app #{app["name"]}\n"
      if app.has_key? "requires_feature"
        print "\t\t..App seems to have been migrated to new descriptor format already. Skipping.\n"
      else
        new_app = Application.new(nil, app["name"], app["uuid"], nil, app["framework"])
        new_app.creation_time = app["creation_time"]
        new_app.aliases = app["aliases"]
        app["embedded"].each do |em,val|
          new_app.requires_feature << em["framework"]
        end
        new_app.send(:elaborate_descriptor)

        app["embedded"].each do |em|
          fw = em["framework"]
          val = em["info"]
          new_app.comp_instance_map.values.each do |comp_inst|
            if comp_inst.parent_cart_name == fw
              comp_inst.cart_data = [val]
            end
          end
        end

        ginst = new_app.group_instance_map.values.uniq.first
        gear = Gear.new(new_app, ginst, new_app.uuid, app["uid"])
        gear.server_identity = app["server_identity"]
        gear.node_profile = app["node_profile"]
        gear.configured_components = new_app.comp_instance_map.keys
        gear.container = nil
        gear.get_proxy
        ginst.gears = [gear]
        app_attrs = new_app.attributes(true)
        print "\t\t..saving\n"
        ds.class.collection.update({ "_id" => user["_id"], "apps.name" => app["name"]}, { "$set" => { "apps.$" => app_attrs }} )
      end
    end
  else
    print "\tNo apps found. skipping\n"
  end
end

