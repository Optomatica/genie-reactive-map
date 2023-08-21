ui = () -> StippleUI.layout(
  [
    quasar(:header, toolbar(
      [
      btn(; dense=true, flat=true, round=true, icon="menu", @click("left_drawer_open = !left_drawer_open")),
      toolbartitle("Genie Reactive Map")
    ],
    ),
    ),
    drawer(
      Html.div(class="q-pa-md", [uploader(label="Upload Dataset", accept=".csv", method="POST", url="http://127.0.0.1:8000/", @on(:uploaded, :uploaded), style="width:100%"),
        # item([itemsection(p("Marker color")), itemsection(input(type="color", var"v-model"=:selected_color, label="Color"))]),
        item(Genie.Renderer.Html.select(:selected_color_feature, clearable=true, options=:features, label="Color based on", useinput=true)),
        item(Genie.Renderer.Html.select(:color_scale, options=:color_scale_options, label="Color Scale", useinput=true, @showif("selected_color_feature"))),
        item(Genie.Renderer.Html.select(:selected_size_feature, clearable=true, options=:features, label="Size based on", useinput=true)),
        item(Genie.Renderer.Html.select(:mapbox_style, options=:mapbox_styles, label="Mapbox Style", useinput=true)),
        item(btn("Show Data", color="primary", icon="view_list", style="font-weight: 600; text-transform: none;", @click("data_show_dialog = true")), @showif("plot_data.lon.length > 0")),
        item(btn("Choose Sample Data", color="primary", icon="grid_view", style="background-color: rgb(239,239,239); font-weight: 600; text-transform: none;", flat=true, @click("show_sample_data_dialog = true"))),
        Html.div(class="q-pa-md q-gutter-sm", [
          StippleUI.dialog(:data_show_dialog, [
              card([
                Genie.Renderer.Html.table(title="View Data", :data_input; pagination=:data_pagination, style="height: 100%;")
              ])
            ], full__height=true, full__width=true)
        ]),
        Html.div(class="q-pa-md q-gutter-sm", [
          StippleUI.dialog(:show_sample_data_dialog, [
            card([
              card_section(
                quasar(:btn__toggle, v__model=:choosen_sample_data, options=:sample_data, style="flex-wrap: wrap")
              ),
              card_actions(
                [
                  btn("Close", color="primary", @click(:confirm_cancel_sample_data)),
                  btn("Show", color="primary", disable! ="!choosen_sample_data", @click(:confirm_choose_sample_data))],
                align="right"
              )
            ])
          ])
        ])
      ]),
      var"v-model"=:left_drawer_open, side="left", bordered=true, overlay=true
    ),
    page_container(
      [
      plot(:trace, layout=:layout, config=:config, configtype=ConfigType, class="window-height"),
      Genie.Renderer.Html.div(
        [
          itemsection(btn(; dense=true, flat=true, round=true, icon="arrow_right", @click(:animate)); avatar=true, @showif("!animate")),
          itemsection(btn(; dense=true, flat=true, round=true, icon="pause", @click("animate = false")); avatar=true, @showif(:animate)),
          itemsection(range("min_year":1:"max_year", :filter_range, label=true, color="blue", labelalways=true)),
        ], style="position: fixed; bottom: 0; right: 0; padding: 12px 40px; background-color: transparent; width: 80%; display: flex; "),
    ]
    ),
  ],
  view="hHh lpR fFf",
  class="window-height"
)



