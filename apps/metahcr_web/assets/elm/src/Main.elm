module Main exposing (main)

{-| This module contains the main function for this application. It is a reimplementation
of the MetaHCR application - Metagenomics of Hydrocarbon Resources - located on
GitHub: <https://github.com/metahcr/metahcr_v1.0> It is responsible for showing
the top-level menu choices and the delegationof user choices to supporting modules.

The data aspect of this application focuses on Investigations and Samples.
Investigations contain one or Samples. Analyses will be added later. Investigations
and Samples modules are found in their respective folders.

The user can "Browse" these data. Searching will be added later. The top-level
functions for browsing are in the Browse module.

-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..) 


-- LOCAL IMPORTS

import MainRest as MR
import MainTypes as MT
import Browse
import Style


-- TYPES


type Page
    = HomePage
    | BrowsePage
    | UserAccess



-- | SearchPage


type alias Model =
    { counts : MT.DataCounts
    , page : Page
    , browseSession : Browse.Session
    , error : Maybe String
    , username : String
    , password : String
    , userValidated : Bool
    , loginStatus : String
    }


type Msg
    = HomeSelected
    | BrowsePageSelected
    | LoginSelected
    | LogoutSelected
    | Username String
    | Password String
    | SubmitLogin
    | BrowseMsg Browse.Msg
    | RestMsg MT.Msg



-- STATE


init : ( Model, Cmd Msg )
init =
    let
        browseSession =
            Browse.init

        mainCmd =
            MR.requestCounts
    in
        ( Model (MT.DataCounts 0 0 0 0) HomePage browseSession Nothing "" "" True ""
        , Cmd.map RestMsg mainCmd
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RestMsg countsMsg ->
            case countsMsg of
                MT.Response dataCounts ->
                    ( updateCounts dataCounts model, Cmd.map BrowseMsg (Browse.load) )

                MT.RequestError error ->
                    ( { model | error = Just error }, Cmd.none )

                MT.LoginResponse loginStatus ->
                    let
                        validation =
                            loginStatus.status == "OK"
                    in
                        ( { model
                            | userValidated = validation
                            , loginStatus = loginStatus.status
                          }
                        , Cmd.none
                        )

        Username username ->
            ( { model | username = username }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        SubmitLogin ->
            ( model, Cmd.map RestMsg (MR.requestLogin model.username model.password) )

        HomeSelected ->
            ( { model | page = HomePage }, Cmd.none )

        BrowsePageSelected ->
            ( { model | page = BrowsePage }, Cmd.none )

        LoginSelected ->
            ( { model | page = UserAccess }, Cmd.none )

        LogoutSelected ->
            init

        BrowseMsg browseMsg ->
            let
                ( newBrowseSession, browseCmd ) =
                    Browse.update browseMsg model.browseSession
            in
                ( { model | browseSession = newBrowseSession }, Cmd.map BrowseMsg browseCmd )


updateCounts : MT.DataCounts -> Model -> Model
updateCounts dataCounts model =
    { model | counts = dataCounts }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ viewNavigationBar model ]
        , div [ style [ ( "margin-top", Style.navBarSize ) ] ]
            [ viewContents model ]
        ]


viewNavigationBar : Model -> Html Msg
viewNavigationBar model =
    div [ class "w3-top" ]
        [ div [ class Style.navBarClass ]
            [ viewHomeMenu model
            , viewBrowseMenu model
            , if model.userValidated then
                div []
                    [ viewLogoutMenu model
                    , span [ class "w3-bar-item" ]
                        [ text ("Welcome " ++ model.username ++ "!") ]
                    ]
              else
                viewLoginMenu model
            ]
        ]


viewHomeMenu : Model -> Html Msg
viewHomeMenu model =
    a
        [ class Style.menuButtonClass
        , onClick HomeSelected
        ]
        [ span [] [ i [ class "fa fa-home" ] [], text " Home" ] ]


viewBrowseMenu : Model -> Html Msg
viewBrowseMenu model =
    let
        disabled =
            if model.userValidated then
                ""
            else
                " w3-disabled"
    in
        button
            [ class (Style.menuButtonClass ++ disabled)
            , onClick BrowsePageSelected
            ]
            [ span [] [ i [ class "fa fa-list" ] [], text " Browse" ] ]


viewLoginMenu : Model -> Html Msg
viewLoginMenu model =
    a
        [ class Style.menuButtonClass
        , onClick LoginSelected
        ]
        [ span [] [ i [ class "fa fa-user" ] [], text " Login" ] ]


viewLogoutMenu : Model -> Html Msg
viewLogoutMenu model =
    a
        [ class Style.menuButtonClass
        , onClick LogoutSelected
        ]
        [ span [] [ i [ class "fa fa-user" ] [], text " Logout" ] ]


viewContents : Model -> Html Msg
viewContents model =
    div []
        [ case model.page of
            HomePage ->
                div []
                    [ div [ class "w3-jumbo w3-center" ]
                        [ text "Welcome to MetHCR v2.0" ]
                    , div [ class "w3-xxlarge w3-center" ]
                        [ text "Metagenomics of Hydrocarbon Resources" ]
                    ]

            BrowsePage ->
                Browse.view model.browseSession |> Html.map BrowseMsg

            UserAccess ->
                if not model.userValidated then
                    loginForm model
                else
                    logoutForm model
        ]


loginForm : Model -> Html Msg
loginForm model =
    div []
        [ br [] []
        , br [] []
        , div [ class "w3-row" ]
            [ div [ class "w3-col l5" ] [ br [] [] ]
            , div
                [ class "w3-col l2 w3-card-4 w3-animate-zoom" ]
                [ div [ class "w3-center" ]
                    [ -- span [ class (Style.menuButtonClass ++ " w3-display-topright") ]
                      --     [ text "X" ]
                      -- ,
                      h2 [] [ text "Login to MetaHCR" ]
                    ]
                , Html.form [ onSubmit SubmitLogin, class "w3-container" ]
                    [ div [ class "w3-section" ]
                        [ label [] [ text "Username" ]
                        , input
                            [ class "w3-input w3-border"
                            , type_ "text"
                            , placeholder "Enter Username"
                            , name "_user"
                            , onInput Username
                            ]
                            []
                        , label [] [ text "Password" ]
                        , input
                            [ class "w3-input w3-border"
                            , type_ "password"
                            , placeholder "Enter Password"
                            , name "_password"
                            , onInput Password
                            ]
                            []
                        , button
                            [ type_ "submit"
                            , class (Style.menuButtonClass ++ " w3-block w3-section w3-padding w3-theme")
                            ]
                            [ text "Login" ]
                        ]
                    ]
                ]
            , div [ class "w3-col l5" ] [ br [] [] ]
            ]
        ]


logoutForm : Model -> Html Msg
logoutForm model =
    div [] []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- PROGRAM


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
