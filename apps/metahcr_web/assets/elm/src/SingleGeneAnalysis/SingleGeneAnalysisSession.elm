module SingleGeneAnalysisSession exposing (update, updateSession, view)

{-| This module handles the viewing and updating of the Investigations in the
Browsing facility.
Please read the documentation for the update function
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- LOCAL IMPORTS

import Style
import SingleGeneAnalysisTypes as SGAT exposing (..)
import SingleGeneAnalysisRest as SGAR exposing (..)
import InvestigationTypes as IT
import InvestigationRest as IR
import SampleTypes as ST
import SampleRest as SR


{-| Note that selecting a Single Gene Analysis results in the viewing of its Sample
This data query is handled by returning a SingleGeneAnalysis Cmd to effect
the query.
-}
update : Action -> Session -> ( Session, Cmd IT.Msg, Cmd ST.Msg, Cmd Msg )
update action session =
    case action of
        ShowHide ->
            ( { session | display = Style.toggle session.display }
            , Cmd.none
            , Cmd.none
            , Cmd.none
            )

        Select singleGeneAnalysis ->
            -- ( session, Cmd.none, Cmd.none, Cmd.none )
            let
                newSession =
                    { session | selection = Just (Selection singleGeneAnalysis Style.Hide) }
            in
                ( newSession
                , IR.requestInvestigations IT.AllInvestigations Style.Hide 1 10
                , SR.requestSamples
                    (ST.SampleForSingleGeneAnalysis singleGeneAnalysis.sample_id singleGeneAnalysis.analysis_name)
                    Style.Hide
                    1
                    10
                , SGAR.requestSingleGeneResults singleGeneAnalysis.analysis_id 1 10
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
                ( { session | selection = newSelection }
                , Cmd.none
                , Cmd.none
                , Cmd.none
                )

        CloseInfosheet ->
            ( { session | selection = Nothing }
            , Cmd.none
            , Cmd.none
            , Cmd.none
            )

        SelectResult result ->
            ( session
            , Cmd.none
            , SR.requestSamples
                (ST.SamplesForOrganism result.organism_id
                    (result.genus ++ " " ++ result.species)
                )
                Style.Hide
                1
                10
            , Cmd.none
            )

        ToggleResults ->
            let
                newResults =
                    case session.results of
                        Nothing ->
                            Nothing

                        Just rs ->
                            Just { rs | display = Style.toggle rs.display }
            in
                ( { session | results = newResults }
                , Cmd.none
                , Cmd.none
                , Cmd.none
                )

        CloseResults ->
            ( { session | results = Nothing }
            , Cmd.none
            , Cmd.none
            , Cmd.none
            )

        Refresh ->
            let
                newSession =
                    { session | selection = Nothing }
            in
                ( newSession
                , IR.requestInvestigations IT.AllInvestigations Style.Hide 1 10
                , SR.requestSamples ST.AllSamples Style.Hide 1 10
                , requestSingleGeneAnalyses AllSingleGeneAnalyses Style.Hide 1 10
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
                , Cmd.none
                , requestSingleGeneAnalyses session.criterion Style.Show newPage session.perPage
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
                , Cmd.none
                , requestSingleGeneAnalyses session.criterion Style.Show newPage session.perPage
                )


updateSession : Msg -> Session -> Session
updateSession restMsg session =
    case restMsg of
        AnalysesResponse ( payload, criterion, display ) ->
            { session
                | total = payload.count
                , list = payload.single_gene_analyses
                , criterion = criterion
                , error = Nothing
                , display = display
                , selection = Nothing
            }

        ResultsResponse payload ->
            { session
                | results =
                    Just (Results payload.single_gene_results Style.Hide)
            }

        RequestError error ->
            { session | error = Just error }


sgaSeparator : Html Action
sgaSeparator =
    div [ class "w3-bar", style [ Style.singleGeneAnalysisColorStyle ] ]
        [ div [ class "w3-bar-item w3-small" ] [ text "  " ] ]


view : Session -> Html Action
view session =
    div []
        [ div
            [ class "w3-bar w3-border w3-border-black"
            , style [ Style.singleGeneAnalysisColorStyle, ( "color", "black" ), ( "font-weight", "bold" ) ]
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

            -- , div [ class "w3-dropdown-hover w3-right" ]
            --     [ div []
            --         [ span
            --             [ class (Style.menuButtonClass ++ " w3-bar-item")
            --             , onClick (Refresh)
            --             ]
            --             [ i [ class "fa fa-bars" ] [ text "       " ] ]
            --         ]
            --
            --     , div [ class "w3-dropdown-content w3-bar-block w3-border", style [ ( "right", "0" ) ] ]
            --         [ a [ href "#", class ("w3-bar-item " ++ Style.menuButtonClass) ] [ text "Selection 1" ]
            --         , a [ href "#", class ("w3-bar-item " ++ Style.menuButtonClass) ] [ text "Selection two" ]
            --         ]
            --     ]
            , div [ class "w3-bar-item w3-border" ]
                [ let
                    criterionText =
                        criterionToText session.criterion
                  in
                    text
                        ((" SINGLE GENE ANALYSES (" ++ (toString session.total) ++ ")")
                            ++ criterionText
                        )
                ]
            ]
        , case session.display of
            Style.Show ->
                div []
                    [ viewAnalyses session
                    , viewInfosheet session
                    , viewResults session
                    ]

            Style.Hide ->
                div [] []
        ]


viewAnalyses : Session -> Html Action
viewAnalyses session =
    div [ class (Style.toClass session.display) ]
        [ viewAnalysisList session
        , viewPagination session
        ]


viewAnalysisList : Session -> Html Action
viewAnalysisList session =
    let
        analyses =
            session.list

        selection =
            session.selection
    in
        if List.length analyses == 0 then
            div [] []
        else
            table
                [ class "w3-table-all" ]
                (List.append
                    [ tr []
                        [ th [] [ text "Analysis Name" ]
                        , th [] [ text "Target Gene" ]
                        , th [] [ text "PCR Primers" ]
                        ]
                    ]
                    (List.map (\a -> viewAnalysis a selection) analyses)
                )


isSelected : SingleGeneAnalysis -> Maybe Selection -> Bool
isSelected analysis selection =
    case selection of
        Nothing ->
            False

        Just s ->
            s.analysis == analysis


viewAnalysis : SingleGeneAnalysis -> Maybe Selection -> Html Action
viewAnalysis analysis selection =
    tr
        [ classList
            [ ( "w3-hover-teal", True )
            , ( Style.selectedColor, isSelected analysis selection )
            ]
        , onClick (Select analysis)
        ]
        [ td [] [ text analysis.analysis_name ]
        , td [] [ text analysis.target_gene ]
        , td [] [ text analysis.pcr_primers ]
        ]


viewInfosheet : Session -> Html Action
viewInfosheet session =
    let
        selection =
            session.selection
    in
        case selection of
            Nothing ->
                div [] []

            Just selection ->
                viewSingleGeneAnalysisInfosheet session selection


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


viewSingleGeneAnalysisInfosheet : Session -> Selection -> Html Action
viewSingleGeneAnalysisInfosheet session selection =
    let
        analysis =
            selection.analysis

        display =
            selection.display
    in
        div []
            [ div
                [ class "w3-bar w3-border w3-border-white"
                , style [ Style.singleGeneAnalysisColorStyle, ( "color", "black" ), ( "font-weight", "bold" ) ]
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
                    [ text (" Infosheet and for Single Gene Analysis " ++ analysis.analysis_name) ]
                ]
            , div [ class (Style.toClass display) ] [ text "INFOSHEET" ]
            ]


viewResults : Session -> Html Action
viewResults session =
    viewSingleGeneResults session session.results


viewSingleGeneResults session results =
    case results of
        Nothing ->
            div [] []

        Just results ->
            div []
                [ div
                    [ class "w3-bar w3-border w3-border-white"
                    , style [ Style.singleGeneAnalysisColorStyle, ( "color", "black" ), ( "font-weight", "bold" ) ]
                    ]
                    [ span
                        [ class (Style.menuButtonClass ++ " w3-left w3-bar-item")
                        , onClick (ToggleResults)
                        ]
                        [ i [ class ("fa " ++ (Style.toPlusOrMinus results.display)) ] [] ]
                    , span
                        [ class (Style.menuButtonClass ++ " w3-left w3-bar-item")
                        , onClick (CloseResults)
                        ]
                        [ i [ class "fa fa-close" ] [] ]
                    , span [ class "w3-bar-item" ]
                        [ text " Single Gene Results " ]
                    ]
                , div [ class (Style.toClass results.display) ] [ viewSingleGeneTable results ]
                ]


viewSingleGeneTable : Results -> Html Action
viewSingleGeneTable results =
    if List.length results.resultsList == 0 then
        div [] [ text " NO RESULTS" ]
    else
        table
            [ class "w3-table-all" ]
            (List.append
                [ tr []
                    [ th [] [ text "Phylum" ]
                    , th [] [ text "Class" ]
                    , th [] [ text "Order" ]
                    , th [] [ text "Family" ]
                    , th [] [ text "Genus" ]
                    , th [] [ text "Species" ]
                    , th [] [ text "Score" ]
                    ]
                ]
                (List.map (\result -> viewResult result) results.resultsList)
            )


viewResult : SingleGeneResult -> Html Action
viewResult result =
    tr
        [ class "w3-hover-teal", onClick (SelectResult result) ]
        [ td [] [ text result.phylum ]
        , td [] [ text result.bio_class ]
        , td [] [ text result.bio_order ]
        , td [] [ text result.family ]
        , td [] [ text result.genus ]
        , td [] [ text result.species ]
        , td [] [ text result.score ]
        ]
