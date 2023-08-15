ui = () -> StippleUI.layout(
  [
    quasar(:header, toolbar(
      [
      btn(; dense=true, flat=true, round=true, icon="menu", @click("left_drawer_open = !left_drawer_open")),
      toolbartitle("World Map")
    ],
    ),
    ),
    drawer(
      [uploader(label="Upload Dataset", accept=".csv", method="POST", url="http://127.0.0.1:8000/", @on(:uploaded, :uploaded), style="width:100%"),
        # item([itemsection(p("Marker color")), itemsection(input(type="color", var"v-model"=:selected_color, label="Color"))]),
        item([
          itemsection(btn(; dense=true, flat=true, round=true, icon="arrow_right", @click(:animate)); avatar=true, @showif("!animate")),
          itemsection(btn(; dense=true, flat=true, round=true, icon="pause", @click("animate = false")); avatar=true, @showif(:animate)),
          itemsection(range("min_year":1:"max_year", :filter_range, label=true, color="purple", labelalways=true)),
        ]),
        item(Genie.Renderer.Html.select(:selected_feature, options=:features, label="Feature", useinput=true)),
        item(Genie.Renderer.Html.select(:color_scale, options=:color_scale_options, label="Color Scale", useinput=true)),
        item(Genie.Renderer.Html.select(:mapbox_style, options=:mapbox_styles, label="Mapbox Style", useinput=true)),
        btn("Show Data", color="primary", @click("data_show_dialog = true")),
        Html.div(class="q-pa-md q-gutter-sm", [
          StippleUI.dialog(:data_show_dialog, [
            card([
              Genie.Renderer.Html.table(title="Random numbers", :data_view; pagination=:data_pagination, style="height: 100%;")
            ])
          ], full__height=true, full__width=true)
        ])
      ],
      var"v-model"=:left_drawer_open, side="left", bordered=true, overlay=true
    ),
    page_container(
      [plot(:trace, layout=:layout, config=:config, configtype=ConfigType, class="window-height")]
    ),
  ],
  view="hHh lpR fFf",
  class="window-height"
)



