module Locomotive
  module Steam
    module Liquid
      module Tags

        # Display the links to change the locale of the current page
        #
        # Usage:
        #
        # {% locale_switcher %} => <div id="locale-switcher"><a href="/features" class="current en">Features</a><a href="/fr/fonctionnalites" class="fr">Fonctionnalités</a></div>
        #
        # {% locale_switcher label: locale %}
        #
        # options:
        #   - label: iso (de, fr, en, ...etc), locale (Deutsch, Français, English, ...etc), title (page title)
        #
        # notes:
        #   - "iso" is the default choice for label
        #

        class LocaleSelector < ::Liquid::Tag

          include Concerns::Attributes
          include Concerns::I18nPage

          attr_reader :attributes, :site, :page, :current_locale, :url_builder

          def initialize(tag_name, markup, options)
            super

            parse_attributes(markup, label: 'iso')
          end

          def render(context)
            evaluate_attributes(context)

            set_vars_from_context(context)

            %{<select id="locale-selector">#{build_site_locales}</select>}
          end

          private

          def build_site_locales
            site.locales.map do |locale|
              change_page_locale(locale, page) do
                path  = link_path(locale)
                option = selected_option(locale)
                %(<option #{option} id="language-selector-iso-#{locale}" value="#{path}">#{link_label(locale)}</option>)
              end
            end
          end
          
          def selected_option(locale)
			option = [locale]
			option << 'selected' if locale.to_sym == current_locale
			option.join(' ')
          end

          def link_path(locale)
            url_builder.url_for(page.send(:_source), locale)
          end

          def link_label(locale)
            case attributes[:label]
            when 'locale' then I18n.t("locomotive.locales.#{locale}")
            when 'title' then page_title
            else
              locale
            end
          end

          def page_title
            if page.templatized?
              page.send(:_source).content_entry._label
            else
              page.title
            end
          end

          def set_vars_from_context(context)
            @context        = context
            @site           = context.registers[:site]
            @page           = context['page']
            @current_locale = context.registers[:locale].to_sym
            @url_builder    = context.registers[:services].url_builder
          end

        end

        ::Liquid::Template.register_tag('locale_selector'.freeze, LocaleSelector)

      end
    end
  end
end
