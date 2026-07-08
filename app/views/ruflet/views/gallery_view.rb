# frozen_string_literal: true

module Showcase
  module Views
    def gallery_view(page)
      route = "/gallery"
      control(:view,
        route: route,
        bgcolor: color_bg(page),
        padding: 0,
        appbar: app_bar(
          bgcolor: color_surface(page),
          color: color_text(page),
          title: text(value: "Gallery", style: { size: 20 }),
          actions: []
        ),
        children: [
          column(
            expand: true,
            spacing: 0,
            children: [
              container(
                expand: true,
                alignment: "center",
                padding: 8,
                content: column(
                  scroll: "auto",
                  spacing: 6,
                  children: gallery_items(page)
                )
              ),
              nav_bar(page, route)
            ]
          )
        ]
      )
    end

    def gallery_items(page)
      [
        tile(page, Ruflet::MaterialIcons::ADD, "Counter", "/counter"),
        tile(page, Ruflet::MaterialIcons::CHECK, "To-do", "/todo"),
        tile(page, Ruflet::MaterialIcons::CALCULATE, "Calculator", "/calculator"),
        tile(page, Ruflet::MaterialIcons::VIEW_MODULE, "Components", "/components"),
        tile(page, Ruflet::MaterialIcons::BRUSH, "Drawing Tool", "/drawing"),
        tile(page, Ruflet::MaterialIcons::PUBLIC, "WebView", "/webview"),
        tile(page, Ruflet::MaterialIcons::VIEW_MODULE, "Material controls", "/material"),
        tile(page, Ruflet::MaterialIcons::SEARCH, "Icon Search", "/icon-search"),
        tile(page, Ruflet::MaterialIcons::SHARE, "Share", "/share"),
        tile(page, Ruflet::MaterialIcons::FLASH_ON, "Flashlight", "/flashlight"),
        tile(page, Ruflet::MaterialIcons::MAP, "Map", "/map"),
        tile(page, Ruflet::MaterialIcons::PHOTO_CAMERA, "Camera", "/camera")
      ]
    end

    def tile(page, icon_value, title, route)
      control(
        :list_tile,
        bgcolor: color_surface(page),
        content_padding: { left: 12, right: 12, top: 8, bottom: 8 },
        leading: icon(icon: icon_value, color: color_icon(page)),
        title: text(value: title, style: { size: 16, color: color_text(page) }),
        trailing: icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT, color: color_subtle(page)),
        on_click: ->(_e) { page.go(route) }
      )
    end
  end
end
