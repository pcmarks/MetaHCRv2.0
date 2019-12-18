module SampleSession exposing (update, updateSession, view)

{-| This module handles the viewing and updating of the Samples in the
Browsing facility.
Please read the documentation for the update function
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- LOCAL IMPORTS

import SampleTypes exposing (..)
import SampleRest exposing (..)
import InvestigationTypes as IT
import InvestigationRest as IR
import SingleGeneAnalysisTypes as SGAT
import SingleGeneAnalysisRest as SGAR
import Style


{-| Note that selecting a Sample results in the viewing of its Investigation
and its SingleGene Analyses session. These two separate data
queries are handled by returning Investigation and SingleGene Analysis Cmd's to effect
the queries.
-}
update : Action -> Session -> ( Session, Cmd IT.Msg, Cmd Msg, Cmd SGAT.Msg )
update action session =
    case action of
        ShowHide ->
            ( { session | display = Style.toggle session.display }, Cmd.none, Cmd.none, Cmd.none )

        Select sample ->
            let
                newSession =
                    { session | selection = Just (Selection sample Style.Hide) }
            in
                ( newSession
                , IR.requestInvestigations
                    (IT.InvestigationForSample
                        sample.id
                        sample.samp_name
                    )
                    Style.Hide
                    1
                    10
                , Cmd.none
                , SGAR.requestSingleGeneAnalyses
                    (SGAT.SingleGeneAnalysesForSample
                        sample.id
                        sample.samp_name
                    )
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
                    { session | selection = Nothing }
            in
                ( newSession
                , IR.requestInvestigations IT.AllInvestigations Style.Hide 1 10
                , requestSamples AllSamples Style.Hide 1 10
                , SGAR.requestSingleGeneAnalyses SGAT.AllSingleGeneAnalyses Style.Hide 1 10
                )

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
                , Cmd.none
                , requestSamples session.criterion Style.Show newPage session.perPage
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
                , Cmd.none
                , requestSamples session.criterion Style.Show newPage session.perPage
                , Cmd.none
                )


{-| updateSession is called to update the Samples's Session without it
resulting in any Html Msg's or Cmd's
-}
updateSession : Msg -> Session -> Session
updateSession restMsg session =
    case restMsg of
        Response ( payload, criterion, display ) ->
            { session
                | total = payload.sampleCount
                , list = payload.samples
                , criterion = criterion
                , error = Nothing
                , display = display
                , selection = Nothing
            }

        RequestError error ->
            { session | error = Just error }



-- VIEW


view : Session -> Html Action
view session =
    div []
        [ div
            [ class "w3-bar w3-border w3-border-black"
            , style [ Style.sampleColorStyle, ( "color", "black" ), ( "font-weight", "bold" ) ]
            ]
            [ span
                [ class (Style.menuButtonClass ++ " w3-left w3-bar-item")
                , onClick (ShowHide)
                ]
                [ i [ class ("fa " ++ (Style.toPlusOrMinus session.display)) ] [] ]
            , span
                [ class (Style.menuButtonClass ++ " w3-left w3-bar-item")
                , onClick (Refresh)
                ]
                [ i [ class "fa fa-refresh" ] [] ]
            , div [ class "w3-bar-item w3-border" ]
                [ let
                    criterionText =
                        criterionToText session.criterion
                  in
                    text ((" SAMPLES (" ++ (toString session.total) ++ ")") ++ criterionText)
                ]
            ]
        , case session.display of
            Style.Show ->
                div []
                    [ viewSamples session

                    -- , viewSelectedS session.selection
                    ]

            Style.Hide ->
                div [] []
        ]


viewSamples : Session -> Html Action
viewSamples session =
    div [ class (Style.toClass session.display) ]
        [ viewSampleList session
        , viewPagination session
        ]


viewSampleList : Session -> Html Action
viewSampleList session =
    let
        samples =
            session.list

        selection =
            session.selection
    in
        if List.length samples == 0 then
            div [] []
        else
            table
                [ class "w3-table-all" ]
                (List.append
                    [ tr []
                        [ th [] [ text "Sample Name" ]
                        , th [] [ text "Description" ]
                        , th [] [ text "Type" ]
                        , th [] [ text "Source Mat." ]
                        ]
                    ]
                    (List.map (\s -> viewSample s selection) samples)
                )


isSelected : Sample -> Maybe Selection -> Bool
isSelected sample selection =
    case selection of
        Nothing ->
            False

        Just s ->
            s.sample == sample


viewSample : Sample -> Maybe Selection -> Html Action
viewSample sample selection =
    tr
        [ classList
            [ ( "w3-hover-teal", True )
            , ( Style.selectedColor, isSelected sample selection )
            ]
        , onClick (Select sample)
        ]
        [ td [] [ text sample.samp_name ]
        , td [] [ text sample.samp_description ]
        , td [] [ text sample.samp_type ]
        , td [] [ text sample.source_mat_id ]
        ]


viewSelectedS : Maybe Selection -> Html Action
viewSelectedS selection =
    case selection of
        Nothing ->
            div [] []

        Just selection ->
            viewInfosheet selection.sample selection.display


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


viewInfosheet : Sample -> Style.Display -> Html Action
viewInfosheet sample display =
    div []
        [ div
            [ class "w3-bar w3-border w3-border-white"
            , style [ Style.sampleColorStyle, ( "color", "white" ) ]
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
                [ text "X" ]
            , span [ class "w3-bar-item" ]
                [ text (" Infosheet for Sample " ++ (toString sample.id)) ]
            ]
        , div [ class (Style.toClass display) ] [ text "INFOSHEET" ]
        ]
