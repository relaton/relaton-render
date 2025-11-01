module Relaton
  module Render
    class I18n
      # @i18n is a hash of IsoDoc::I18n objects, selected from according to
      # attributes of the parsed Relaton object
      def initialize(opt)
        opt = Utils::string_keys(opt)
        if opt["i18n_multi"]
          @i18n = opt["i18n_multi"]
        elsif opt["i18n"]
          @i18n = { "" => opt["i18n"] }
        else
          raise error "Bad configuration, Relaton::Render::I18n"
        end
      end

      # obj is the biblio hash, extracted by Relaton::Render::Fields
      # There must always be a default selection, for obj = nil,
      # being the document language setting. If select is applied on obj,
      # the i18n selected is appropriate to the citation specifically,
      # and potentially to the field specificaly
      def select(obj)
        if obj.nil? then select_default
        else select_obj(obj)
        end
      end

      def select_default
        @i18n[""]
      end

      def select_obj(_obj)
        @i18n[""]
      end

      def config
        @i18n
      end
    end
  end
end
