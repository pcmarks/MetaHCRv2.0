module InvestigationSession exposing (update, updateSession, view)

{-| This module handles the viewing and updating of the Investigations in the
Browsing facility.
Please read the documentation for the update function
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date.Format


-- LOCAL IMPORTS

import InvestigationTypes exposing (..)
import InvestigationRest exposing (..)
import SampleTypes as ST
import SampleRest as SR
import SingleGeneAnalysisTypes as SGAT
import SingleGeneAnalysisRest as SGAR
import Style


{-| Note that selecting an Investigation results in the viewing of its Samples
and the resetting of the SingleGene Analyses session. These two separate data
queries are handled by returning Sample and SingleGene Analysis Cmd's to effect
the queries.
-}
update : Action -> Session -> ( Session, Cmd Msg, Cmd ST.Msg, Cmd SGAT.Msg )
update action session =
    case action of
        ShowHide ->
            ( { session | display = Style.toggle session.display }, Cmd.none, Cmd.none, Cmd.none )

        Select investigation ->
            let
                newSession =
                    { session | selection = Just (Selection investigation Style.Hide) }
            in
                ( newSession
                , Cmd.none
                , SR.requestSamples
                    (ST.SamplesForInvestigation investigation.id investigation.project_name)
                    Style.Hide
                    1
                    10
                , SGAR.requestSingleGeneAnalyses
                    SGAT.AllSingleGeneAnalyses
                    Style.Hide
                    1
                    10
                )

        ToggleInfosheet ->
            let
                newSelection =
                    case session.selection of
                        Nothing ->
                            Nothing

                        Just s ->
                            Just { s | display = Style.toggle s.display }
            in
                ( { session | selection = newSelection }, Cmd.none, Cmd.none, Cmd.none )

        CloseInfosheet ->
            ( { session | selection = Nothing }, Cmd.none, Cmd.none, Cmd.none )

        Refresh ->
            let
                newSession =
                    { session | selection = Nothing, filterName = "" }
            in
                ( newSession
                , requestInvestigations
                    AllInvestigations
                    session.display
                    1
                    10
                , SR.requestSamples
                    ST.AllSamples
                    Style.Hide
                    1
                    10
                , SGAR.requestSingleGeneAnalyses
                    SGAT.AllSingleGeneAnalyses
                    Style.Hide
                    1
                    10
                )

        Search ->
            ( { session | searchDisplay = Style.toggle session.searchDisplay }, Cmd.none, Cmd.none, Cmd.none )

        NextPage ->
            let
                totalPages =
                    ceiling (toFloat session.total / toFloat session.perPage)

                newPage =
                    if session.page == totalPages then
                        totalPages
                    else
                        session.page + 1
            in
                ( { session | page = newPage }
                , requestInvestigations session.criterion Style.Show newPage session.perPage
                , Cmd.none
                , Cmd.none
                )

        PreviousPage ->
            let
                newPage =
                    if session.page == 1 then
                        1
                    else
                        session.page - 1
            in
                ( { session | page = newPage }
                , requestInvestigations session.criterion Style.Show newPage session.perPage
                , Cmd.none
                , Cmd.none
                )

        ProjectName name ->
            ( { session | filterName = name }
            , requestInvestigationsFilter "project_name" name Style.Show 1 10
            , Cmd.none
            , Cmd.none
            )

        Description name ->
            ( { session | filterName = name }
            , requestInvestigationsFilter "investigation_description" name Style.Show 1 10
            , Cmd.none
            , Cmd.none
            )


{-| updateSession is called to update the Investigation's Session without it
resulting in any Html Msg's or Cmd's
-}
updateSession : Msg -> Session -> Session
updateSession restMsg session =
    case restMsg of
        Response ( payload, criterion, display ) ->
            { session
                | total = payload.investigationCount
                , list = payload.investigations
                , criterion = criterion
                , error = Nothing
                , display = display
                , selection = Nothing
            }

        RequestError error ->
            { session
                | error = Just error
            }


view : Session -> Html Action
view session =
    div []
        [ div
            [ class "w3-bar w3-border w3-border-black"
            , style [ Style.investigationColorStyle, ( "color", "black" ), ( "font-weight", "bold" ) ]
            ]
            [ span
                [ class
                    (Style.menuButtonClass
                        ++ " w3-left w3-bar-item"
                    )
                , onClick (ShowHide)
                ]
                [ i [ class ("fa " ++ (Style.toPlusOrMinus session.display)) ] [] ]
            , span
                [ class (Style.menuButtonClass ++ " w3-left w3-bar-item")
                , onClick (Refresh)
                ]
                [ i [ class "fa fa-refresh" ] [] ]

            -- , span
            --     [ class (Style.menuButtonClass ++ " w3-left w3-bar-item")
            --     , onClick (Search)
            --     ]
            --     [ i [ class "fa fa-search" ] [] ]
            , div [ class "w3-bar-item w3-border " ]
                [ let
                    criterionText =
                        criterionToText session.criterion
                  in
                    text
                        ((" INVESTIGATIONS (" ++ (toString session.total) ++ ")")
                            ++ criterionText
                        )
                ]
            ]
        , case session.error of
            Nothing ->
                div [] []

            Just error ->
                div [ class "w3-panel w3-red" ]
                    [ p [] [ text error ] ]
        , case session.searchDisplay of
            Style.Show ->
                viewSearch session

            Style.Hide ->
                text ""
        , case session.display of
            Style.Show ->
                div []
                    [ viewInvestigations session

                    -- , viewSelectedI session.selection
                    ]

            Style.Hide ->
                div [] []
        ]


viewSearch : Session -> Html Action
viewSearch session =
    div []
        [ table [ class "w3-bordered", style [ ( "width", "100%" ) ] ]
            [ -- thead []
              --     [ tr []
              --         [ td [] [ text "Field Name" ]
              --         , td [] [ text "Operator" ]
              --         , td [] [ text "Value" ]
              --         ]
              --     ],
              tbody []
                [ tr []
                    [ td [ style [ ( "width", "40%" ) ] ]
                        [ select [ class "w3-select w3-border w3-round" ]
                            [ option [ value "", disabled True, selected True ] [ text "Choose a field" ]
                            , option [ value "description" ] [ text "Description" ]
                            , option [ value "project_name" ] [ text "Project Name" ]
                            ]
                        ]
                    , td [ style [ ( "width", "20%" ) ] ]
                        [ select [ class "w3-select w3-border w3-round" ]
                            [ option [ value "", disabled True, selected True ] [ text "Choose an operator" ]
                            , option [ value "contains" ] [ text "contains" ]
                            , option [ value "=" ] [ text "equals" ]
                            , option [ value "!=" ] [ text "does not equal" ]
                            ]
                        ]
                    , td [ style [ ( "width", "40%" ) ] ]
                        [ input
                            [ class "w3-input w3-border w3-round"
                            , type_ "text"
                            , placeholder "Enter an appropriate value"
                            ]
                            []
                        ]
                    , td []
                        [ span
                            [ class (Style.menuButtonClass ++ " w3-left w3-bar-item")

                            -- , onClick (Search)
                            ]
                            [ i [ class "fa fa-search-plus" ] [] ]
                        ]
                    ]
                ]
            ]
        , div [ class "w3-center" ]
            [ div [ class "w3-bar w3-padding-large w3-border" ]
                [ button [ class "w3-button w3-border w3-margin-right" ] [ text "Search!" ]
                , button [ class "w3-button w3-border w3-margin-left" ] [ text "Clear!" ]
                ]
            ]
        , entitySeparator
        ]


entitySeparator : Html Action
entitySeparator =
    div [ class "w3-bar", style [ Style.investigationColorStyle ] ]
        [ div [ class "w3-bar-item" ] [ text "  " ] ]


viewInvestigations : Session -> Html Action
viewInvestigations session =
    div [ class (Style.toClass session.display) ]
        [ viewInvestigationList session
        , viewPagination session
        ]


viewInvestigationList : Session -> Html Action
viewInvestigationList session =
    let
        investigations =
            session.list

        selection =
            session.selection

        headingsOnly =
            List.length investigations == 0 && session.filterName == ""
    in
        if headingsOnly then
            div [] []
        else
            table
                [ class "w3-table-all" ]
                (List.append
                    [ tr []
                        [ th [] [ text "Project Name" ]
                        , th [] [ text "Description" ]
                        , th [] [ text "Completion Date" ]
                        ]
                    , tr []
                        [ td []
                            [ input
                                [ type_ "text"
                                , class "w3-animate-input w3-border w3-round-large"
                                , style [ ( "width", "30%" ) ]
                                , onInput ProjectName
                                ]
                                []
                            ]
                        , td []
                            [ input
                                [ type_ "text"
                                , class "w3-animate-input w3-border w3-round-large"
                                , style [ ( "width", "30%" ) ]
                                , onInput Description
                                ]
                                []
                            ]
                        , td [] []
                        ]
                    ]
                    (List.map (\i -> viewInvestigationRow i selection) investigations)
                )


isSelected : Investigation -> Maybe Selection -> Bool
isSelected investigation selection =
    case selection of
        Nothing ->
            False

        Just s ->
            s.investigation == investigation


viewInvestigationRow : Investigation -> Maybe Selection -> Html Action
viewInvestigationRow investigation selection =
    let
        cDate =
            case investigation.completion_date of
                Nothing ->
                    ""

                Just date ->
                    Date.Format.format "%Y-%m-%d" date
    in
        tr
            [ classList
                [ ( "w3-hover-teal", True )
                , ( Style.selectedColor, isSelected investigation selection )
                ]
            , onClick (Select investigation)
            ]
            [ td [] [ text (String.left 60 investigation.project_name) ]
            , td [] [ text (String.left 60 investigation.investigation_description) ]
            , td [] [ text cDate ]
            ]


viewSelectedI : Maybe Selection -> Html Action
viewSelectedI selection =
    case selection of
        Nothing ->
            div [] []

        Just selection ->
            viewInfosheet selection.investigation selection.display


viewPagination : Session -> Html Action
viewPagination session =
    if session.total > session.perPage then
        div [ class "w3-bar w3-large" ]
            [ span
                [ class (Style.menuButtonClass ++ "w3-khaki w3-left w3-bar-item")
                , onClick PreviousPage
                ]
                [ i [ class "fa fa-angle-double-left" ]
                    []
                ]
            , span
                [ class (Style.menuButtonClass ++ "w3-khaki w3-bar-item")
                , onClick NextPage
                ]
                [ i [ class "fa fa-angle-double-right" ]
                    []
                ]
            ]
    else
        div [] []


viewInfosheet : Investigation -> Style.Display -> Html Action
viewInfosheet investigation display =
    div []
        [ div
            [ class "w3-bar w3-border w3-border-black"
            , style [ Style.investigationColorStyle, ( "color", "white" ) ]
            ]
            [ span
                [ class (Style.menuButtonClass ++ " w3-left w3-bar-item")
                , onClick (ToggleInfosheet)
                ]
                [ i [ class ("fa " ++ (Style.toPlusOrMinus display)) ] [] ]
            , span
                [ class (Style.menuButtonClass ++ " w3-left w3-bar-item")
                , onClick (CloseInfosheet)
                ]
                [ i [ class "fa fa-close" ] [] ]
            , span [ class "w3-bar-item" ]
                [ text (" Infosheet for Investigation " ++ (toString investigation.id)) ]
            ]
        , div [ class (Style.toClass display) ]
            [ div [ class "w3-cell-row" ]
                [ div [ class "w3-container w3-border w3-cell" ]
                    [ text "Field 1" ]
                , div [ class "w3-container w3-border w3-cell" ]
                    [ text "Field 2" ]
                , div [ class "w3-container w3-border w3-cell" ]
                    [ text "Field 3" ]
                ]
            ]
        ]
