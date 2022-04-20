module Relaton
  module Render
    BIBTYPE =
      %w(article book booklet manual proceedings presentation thesis techreport
         standard unpublished map electronic_resource audiovisual film video
         broadcast software graphic_work music patent inbook incollection
         inproceedings journal website webresource dataset archival social_media
         alert message conversation misc internal).freeze

    class General
      singleton_class.send(:attr_reader, :descendants)
      @descendants = {}

      def self.inherited(subclass) # rubocop:disable Lint/MissingSuper
        type = subclass.name.downcase.sub(/relaton::render::/, "")
        General.descendants[type] = subclass
      end

      def self.subclass(type)
        @descendants[type]
      end
    end

    class Book < General
    end

    class Journal < General
    end

    class Booklet < General
    end

    class Manual < General
    end

    class Proceedings < General
    end

    class Presentation < General
    end

    class Thesis < General
    end

    class Techreport < General
    end

    class Standard < General
    end

    class Unpublished < General
    end

    class Map < General
    end

    class Electronic_resource < General
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

    class Audiovisual < General
    end

    class Film < Audiovisual
    end

    class Video < Audiovisual
    end

    class Broadcast < Audiovisual
    end

    class Graphic_work < General
    end

    class Music < General
    end

    class Patent < General
    end

    class Hosted < General
    end

    class Article < Hosted
    end

    class InBook < Hosted
    end

    class InCollection < Hosted
    end

    class InProceedings < Hosted
    end

    class Archival < General
    end

    class Conversation < General
    end

    class Misc < General
    end

    class Internal < General
    end
  end
end
