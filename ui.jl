
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
      [uploader(label="Upload Dataset", accept=".csv", method="POST", url="http://127.0.0.1:8000/", @on(:uploaded, :uploaded), style="width:200px"),
        item([itemsection(p("Marker color")), itemsection(input(type="color", var"v-model"=:selected_color, label="Color"))]),
        item([itemsection(btn(; dense=true, flat=true, round=true, icon="arrow_right"); avatar=true),
              itemsection(range("min_year":1:"max_year", :filter_range, label=true, color="purple", labelalways=true)),
              ]),
        item(Genie.Renderer.Html.select(:selected_feature, options=:features, label="Feature", useinput=true))
      ],
      var"v-model"=:left_drawer_open, side="left", width=200, bordered=true, overlay=true
    ),
    page_container(
      plot(:trace, layout=:layout, class="window-height")
    ),
  ],
  view="hHh lpR fFf",
  class="window-height"
)

