module OrganismSession exposing (update, updateSession, view)

{-| This module handles the viewing and updating of the Organisms in the
Browsing facility. Please read the documentation for the update function
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- LOCAL IMPORTS

import OrganismTypes exposing (..)
import OrganismRest exposing (..)
import SampleTypes as ST
import SampleRest as SR
import Style


{-| Note that selecting an Organism results in the viewing of its
Biological Analyses and the resetting of the Biological Analyses sessions.
This query results in the returning of a BiologicalAnalysis Cmdeffect
the query.
-}
update : Action -> Session -> ( Session, Cmd ST.Msg, Cmd Msg )
update action session =
    case action of
        ShowHide ->
            ( { session | display = Style.toggle session.display }
            , Cmd.none
            , Cmd.none
            )

        Select organism ->
            ( session
            , SR.requestSamples
                (ST.SamplesForOrganism organism.id
                    (organism.genus ++ " " ++ organism.species)
                )
                Style.Hide
                1
                10
            , Cmd.none
            )

        ToggleInfosheet ->
            ( session
            , Cmd.none
            , Cmd.none
            )

        CloseInfosheet ->
            ( session
            , Cmd.none
            , Cmd.none
            )

        Refresh ->
            ( session
            , Cmd.none
            , requestOrganisms AllOrganisms 2 10
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
                ( { session | page = newPage, display = Style.Show }
                , Cmd.none
                , requestOrganisms session.criterion newPage session.perPage
                )

        PreviousPage ->
            let
                newPage =
                    if session.page == 1 then
                        1
                    else
                        session.page - 1
            in
                ( { session | page = newPage, display = Style.Show }
                , Cmd.none
                , requestOrganisms session.criterion newPage session.perPage
                )


{-| updateSession is called to update the Organism's Session without it
resulting in any Html Msg's or Cmd's
-}
updateSession : Msg -> Session -> Session
updateSession restMsg session =
    case restMsg of
        Response ( payload, criterion ) ->
            { session
                | total = payload.organismCount
                , list = payload.organisms
                , criterion = criterion
                , error = Nothing
                , selection = Nothing
            }

        RequestError error ->
            { session | error = Just error }


view : Session -> Html Action
view session =
    div []
        [ div
            [ class "w3-bar w3-border w3-border-black"
            , style [ Style.organismColorStyle, ( "color", "black" ), ( "font-weight", "bold" ) ]
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
            , div [ class "w3-bar-item w3-border" ]
                [ let
                    criterionText =
                        criterionToText session.criterion
                  in
                    text ((" ORGANISMS (" ++ (toString session.total) ++ ")") ++ criterionText)
                ]
            ]
        , case session.display of
            Style.Show ->
                div []
                    [ viewOrganisms session
                    , viewSelected session.selection
                    ]

            Style.Hide ->
                div [] []
        ]


viewOrganisms : Session -> Html Action
viewOrganisms session =
    div [ class (Style.toClass session.display) ]
        [ viewOrganismList session
        , viewPagination session
        ]


viewOrganismList : Session -> Html Action
viewOrganismList session =
    let
        organisms =
            session.list

        selection =
            session.selection
    in
        if List.length organisms == 0 then
            div [] []
        else
            table
                [ class "w3-table-all" ]
                (List.append
                    [ tr []
                        [ th [] [ text "Super Kingdom" ]
                        , th [] [ text "Phylum" ]
                        , th [] [ text "Subphylum" ]
                        , th [] [ text "Class" ]
                        , th [] [ text "Order" ]
                        , th [] [ text "Family" ]
                        , th [] [ text "Genus" ]
                        , th [] [ text "Species" ]
                        ]
                    ]
                    (List.map (\o -> viewOrganism o selection) organisms)
                )


isSelected : Organism -> Maybe Selection -> Bool
isSelected organism selection =
    case selection of
        Nothing ->
            False

        Just s ->
            s.organism == organism


viewOrganism : Organism -> Maybe Selection -> Html Action
viewOrganism organism selection =
    tr
        [ classList
            [ ( "w3-hover-teal", True )
            , ( Style.selectedColor, isSelected organism selection )
            ]
        , onClick (Select organism)
        ]
        [ td [] [ text organism.superkingdom ]
        , td [] [ text organism.phylum ]
        , td [] [ text organism.subphylum ]
        , td [] [ text organism.bio_class ]
        , td [] [ text organism.bio_order ]
        , td [] [ text organism.family ]
        , td [] [ text organism.genus ]
        , td [] [ text organism.species ]
        ]


viewSelected : Maybe Selection -> Html Action
viewSelected selection =
    case selection of
        Nothing ->
            div [] []

        Just selection ->
            viewInfosheet selection.organism selection.display


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


viewInfosheet : Organism -> Style.Display -> Html Action
viewInfosheet organism display =
    div []
        [ div
            [ class "w3-bar w3-border w3-border-white"
            , style [ Style.organismColorStyle, ( "color", "white" ) ]
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
                [ text (" Infosheet for Organism " ++ (toString organism.id)) ]
            ]
        , div [ class (Style.toClass display) ] [ text "INFOSHEET" ]
        ]
