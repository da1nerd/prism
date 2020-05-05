require "./spec_helper"

module Prism
  describe Prism::OBJ do
    it "loads a raw 3d model file" do
      data = Prism::OBJ.load(File.join(__DIR__, "./obj/grass.obj"))
    end
  end

  describe Prism::Model do
    it "loads a 3d model" do
        model = Prism::Model.load(File.join(__DIR__, "./obj/grass.obj"))
    end
  end
end
