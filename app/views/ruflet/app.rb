# frozen_string_literal: true

require "ruflet"

require_relative "helpers"
require_relative "views/navigation_bar"
require_relative "views/gallery_view"
require_relative "views/home_view"
require_relative "views/settings_view"
require_relative "views/detail_view"
require_relative "views/status_text"
require_relative "sections_controls"
require_relative "sections_media"
require_relative "sections_misc"

module Showcase
  class App < Ruflet::App
    include Helpers
    include Views
    include SectionsControls
    include SectionsMedia
    include SectionsMisc

    def view(page)
      page.title = "Gallery"
      page.scroll = "auto"
      page.bgcolor = color_bg(page)
      page.theme_mode = theme_mode

      page.on_route_change = ->(_e) { render(page) }
      page.on_platform_brightness_change = ->(_e) { render(page) }

      render(page)
    end

    private

    def render(page)
      route = route_path(page.route)
      route = "/gallery" if route == "/"
      page.bgcolor = color_bg(page)
      page.theme_mode = theme_mode

      if route.start_with?("/components/")
        slug = route.split("/").last
        page.views = [detail_view(page, component_title(slug), build_component_detail(page, status_text(page), slug),
                                  source_path: "showcase/sections_controls/components.rb",
                                  back_route: "/components")]
        page.update
        return
      end

      case route
      when "/home"
        page.views = [home_view(page)]
      when "/gallery"
        page.views = [gallery_view(page)]
      when "/settings"
        page.views = [settings_view(page)]
      when "/counter"
        page.views = [detail_view(page, "Counter", build_counter(page, status_text(page)),
                                  source_path: "showcase/sections_controls/counter.rb")]
      when "/todo"
        page.views = [detail_view(page, "To-do", build_todo(page, status_text(page)),
                                  source_path: "showcase/sections_controls/todo.rb")]
      when "/calculator"
        page.views = [detail_view(page, "Calculator", build_calculator(page, status_text(page)),
                                  source_path: "showcase/sections_controls/calculator.rb")]
      when "/components"
        page.views = [detail_view(page, "Components", build_components(page, status_text(page)),
                                  source_path: "showcase/sections_controls/components.rb")]
      when "/drawing"
        page.views = [detail_view(page, "Drawing Tool", build_drawing(page, status_text(page)),
                                  source_path: "showcase/sections_drawing.rb")]
      when "/material"
        page.views = [detail_view(page, "Material controls", build_material_controls(page, status_text(page)),
                                  source_path: "showcase/sections_controls/material_controls.rb")]
      when "/icon-search"
        page.views = [detail_view(page, "Icon Search", build_icon_search(page, status_text(page)),
                                  source_path: "showcase/sections_misc/icon_search.rb")]
      when "/share"
        page.views = [detail_view(page, "Share", build_share(page, status_text(page)),
                                  source_path: "showcase/sections_media/share.rb")]
      when "/webview"
        page.views = [detail_view(page, "WebView", build_webview(page, status_text(page)),
                                  source_path: "showcase/sections_media/webview.rb",
                                  scroll: nil,
                                  horizontal_alignment: "stretch",
                                  padding: 0)]
      when "/flashlight"
        page.views = [detail_view(page, "Flashlight", build_flashlight(page, status_text(page)),
                                  source_path: "showcase/sections_media/flashlight.rb")]
      when "/camera"
        page.views = [detail_view(page, "Camera", build_camera(page, status_text(page)),
                                  source_path: "showcase/sections_media/camera.rb")]
      when "/map"
        page.views = [detail_view(page, "Map", build_map(page, status_text(page)),
                                  source_path: "showcase/sections_media/map.rb",
                                  scroll: nil,
                                  horizontal_alignment: "stretch",
                                  padding: 0)]
      else
        page.views = [gallery_view(page)]
      end

      page.update
    end

    def route_path(route)
      route.to_s.split("?").first
    end
  end
end
