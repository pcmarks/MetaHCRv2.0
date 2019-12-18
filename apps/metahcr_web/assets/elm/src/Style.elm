module Style exposing (..)

{-| Various and Sundry W3.CSS settings and functions for page styling.
-}


type Display
    = Show
    | Hide


toggle : Display -> Display
toggle display =
    case display of
        Show ->
            Hide

        Hide ->
            Show


toClass : Display -> String
toClass display =
    case display of
        Show ->
            " w3-show "

        Hide ->
            " w3-hide "


toPlusOrMinus : Display -> String
toPlusOrMinus display =
    case display of
        Show ->
            " fa fa-minus "

        Hide ->
            " fa fa-plus "


navBarSize =
    "40px"


navBarClass =
    "w3-bar w3-theme w3-border "


menuButtonClass =
    "w3-bar-item w3-button w3-hoverable w3-hover-orange w3-border w3-border-black"


investigationColorStyle =
    ( "background", "#37a56e" )


sampleColorStyle =
    ( "background", "#74ae46" )


singleGeneAnalysisColorStyle =
    ( "background", "#b6b013" )


biologicalAnalysisColorStyle =
    ( "background", "#b6b013" )


organismColorStyle =
    ( "background", "#ffa600" )


selectedColorStyle =
    ( "background", "#d5ae00" )


selectedColor =
    "w3-light-blue"
