class Iso690Render
  BIBTYPE =
    %i(article book booklet manual proceedings presentation thesis techreport
       standard unpublished map electronic_resource audiovisual film video
       broadcast software graphic_work music patent inbook incollection
       inproceedings journal website webresource dataset archival social_media
       alert message conversation misc).freeze

  singleton_class.send(:attr_reader, :descendants)
  @descendants = {}

  def self.inherited(subclass) # rubocop:disable Lint/MissingSuper
    Iso690Render.descendants[subclass.name.downcase.to_sym] = subclass
  end

  def self.subclass(type)
    @descendants[type]
  end
end

class Book < Iso690Render
end

class Journal < Iso690Render
end

class Booklet < Iso690Render
end

class Manual < Iso690Render
end

class Proceedings < Iso690Render
end

class Presentation < Iso690Render
end

class Thesis < Iso690Render
end

class Techreport < Iso690Render
end

class Standard < Iso690Render
end

class Unpublished < Iso690Render
end

class Map < Iso690Render
end

class Electronic_resource < Iso690Render
end

class Software < Electronic_resource
end

class Webresource < Electronic_resource
end

class Website < Webresource
end

class Dataset < Electronic_resource
end

class Social_media < Electronic_resource
end

class Alert < Social_media
end

class Message < Social_media
end

class Audiovisual < Iso690Render
end

class Film < Audiovisual
end

class Video < Audiovisual
end

class Broadcast < Audiovisual
end

class Graphic_work < Iso690Render
end

class Music < Iso690Render
end

class Patent < Iso690Render
end

class Hosted < Iso690Render
end

class Article < Hosted
end

class InBook < Hosted
end

class InCollection < Hosted
end

class InProceedings < Hosted
end

class Archival < Iso690Render
end

class Conversation < Iso690Render
end

class Misc < Iso690Render
end
