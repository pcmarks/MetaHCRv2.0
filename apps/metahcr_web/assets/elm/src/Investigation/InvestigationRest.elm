module InvestigationRest
    exposing
        ( requestInvestigations
        , requestInvestigationsFilter
        )

{-| This module provides database query support for Investigations.
-}

import Http exposing (Request)
import Json.Decode exposing (andThen, nullable, map, bool, int, string, list, succeed, fail, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode
import Date exposing (Date)
import Date.Format


-- LOCAL IMPORTS

import Rest exposing (..)
import InvestigationTypes exposing (..)
import Misc exposing (date)
import Style exposing (Display)


requestInvestigations : Criterion -> Display -> Int -> Int -> Cmd Msg
requestInvestigations criterion display page perPage =
    Http.send
        (\result ->
            case result of
                Ok investigationsPayload ->
                    Response ( investigationsPayload, criterion, display )

                Err httpErr ->
                    RequestError (toString httpErr)
        )
        (getInvestigations criterion display page perPage)


getInvestigations : Criterion -> Display -> Int -> Int -> Request InvestigationsPayload
getInvestigations criterion display page perPage =
    let
        parms =
            case criterion of
                AllInvestigations ->
                    investigationsParms page perPage

                InvestigationForSample sampleId description ->
                    investigationsParms page perPage
                        ++ ("&samp_id=" ++ (toString sampleId))
    in
        Http.get (browseUrl ++ "/investigation" ++ parms) investigationsDecoder


requestInvestigationsFilter : String -> String -> Display -> Int -> Int -> Cmd Msg
requestInvestigationsFilter col val display page perPage =
    Http.send
        (\result ->
            case result of
                Ok investigationsPayload ->
                    Response ( investigationsPayload, AllInvestigations, display )

                Err httpErr ->
                    RequestError (toString httpErr)
        )
        (filterInvestigations col val display page perPage)


filterInvestigations : String -> String -> Display -> Int -> Int -> Request InvestigationsPayload
filterInvestigations col val display page perPage =
    let
        parms =
            investigationsParms page perPage
                ++ ("&col=" ++ col ++ "&val=" ++ val)
    in
        Http.get (browseUrl ++ "/investigation" ++ parms) investigationsDecoder



-- Request val


investigationsParms : Int -> Int -> String
investigationsParms startPage itemCount =
    "?page=" ++ (toString startPage) ++ "&itemcount=" ++ (toString itemCount)


investigationsDecoder : Decoder InvestigationsPayload
investigationsDecoder =
    decode InvestigationsPayload
        |> Pipeline.required "count" int
        |> Pipeline.required "investigations" (Json.Decode.list investigationDecoder)


investigationDecoder : Decoder Investigation
investigationDecoder =
    decode Investigation
        |> Pipeline.required "id" int
        |> Pipeline.required "project_name" string
        |> Pipeline.required "experimental_factor" string
        |> Pipeline.required "investigation_type" string
        |> Pipeline.required "submitted_to_insdc" bool
        |> Pipeline.required "availability" string
        |> Pipeline.required "completion_date" (nullable date)
        |> Pipeline.required "ncbi_project_id" string
        |> Pipeline.required "investigation_description" string
